//
//  Aesthete.swift
//  Aesthete IOS
//
//  Created by Alexander Lezya on 09.11.2021.
//

import Foundation
import ObserverList

// MARK: - Aesthete

public final class AestheteImplementation: NSObject {

    // MARK: - Properties

    /// Observers list array
    private let observers = ObserverList<AestheteObserving>()

    /// Cuncurrent array
    private var items: ConcurrentArray<DownloadItem>

    /// Limited operation group
    private let group: LimitedOperationGroup

    /// AestheteConfiguration instance
    private let configuration: AestheteConfiguration

    /// Last error
    private var lastError: Error?

    /// DownloadsFileManagerProtocol instance
    private let fileManager: DownloadsFileManagerProtocol

    /// URLSession iinstance
    private var session: URLSession?

    // MARK: - Initializers

    /// Ddefault initialzer
    /// - Parameters:
    ///   - configuration: AestheteConfiguration
    ///   - fileManager: DownloadsFileManagerProtocol instance
    ///   - delegateQueue: DispatchQueue instance
    init(
        configuration: AestheteConfiguration = AestheteConfiguration.default,
        fileManager: DownloadsFileManagerProtocol = DownloadsFileManager(withBaseDownloadsDirectoryName: "Downloads"),
        delegateQueue: DispatchQueue = DispatchQueue.main
    ) {
        self.items = ConcurrentArray<DownloadItem>()
        self.configuration = configuration
        self.group = configuration.limitedGroup()
        self.fileManager = fileManager
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.waitsForConnectivity = true
        super.init()
        self.session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: configuration.queue)
    }

    /// Convinience initializer with default configuration
    /// - Parameters:
    ///   - configuration: AestheteConfiguration instance
    ///   - delegateQueue: DispatchQueue instance
    public convenience init(
        configuration: AestheteConfiguration = AestheteConfiguration.default,
        delegateQueue: DispatchQueue = DispatchQueue.main
    ) {
        self.init(
            configuration: configuration,
            fileManager: DownloadsFileManager(withBaseDownloadsDirectoryName: configuration.baseDownloadsDirectoryName),
            delegateQueue: delegateQueue
        )
    }
}

// MARK: - Aesthete

extension AestheteImplementation: Aesthete {

    public func add(observer: AnyObject, closures: AestheteObserving) {
        observers.addObserver(disposable: observer, observer: closures)
    }

    public func remove(observer: AnyObject) {
        observers.removeObserver(disposable: observer)
    }

    public func enqueueMultipleDownloads(forResources resources: [DownloadResource]) throws {
        try resources.forEach { try enqueueDownload(forResource: $0) }
    }

    public func enqueueDownload(forResource resource: DownloadResource) throws {
        cleanQueueStatisticsIfNeeded()
        let item = try DownloadItem(resource: resource, fileManager: fileManager, session: session.unsafelyUnwrapped)
        switch resource.mode {
        case .newFile:
            items.append(item)
        case .notDownloadIfExists:
            if let existing = existingFileIfAvailable(forExpectedFilename: resource.destinationName) {
                observers.forEach { closures in
                    closures.downloadFinishedClosure?(resource, item.task, existing)
                }
                item.cancel()
            } else {
                guard !(items.contains { $0.resource.destinationName == resource.destinationName }) else { return }
                items.append(item)
            }
        }
        createAndScheduleOperation(forItem: item)
    }

    public func cancel(downloadingResourcesWithId id: String) {
        items
            .filter { $0.resource.id == id }
            .forEach {
                $0.cancel()
                remove(downloadItem: $0)
            }
    }

    public func cancelAllDownloads() {
        items.forEach { $0.cancel() }
        items.removeAll()
    }

    public func downloadTask(forResource resource: DownloadResource) -> URLSessionDownloadTask? {
        downloadTask(forResourceWithId: resource.id)
    }

    public func downloadTask(forResourceWithId resourceId: String) -> URLSessionDownloadTask? {
        items.first { $0.resource.id == resourceId }?.task
    }

    public func isDownloading(resourceWithId id: String) -> Bool {
        items.contains { $0.resource.id == id }
    }

    public func cleanDownloadsDirectory() throws {
        try fileManager.cleanDownloadsDirectory()
    }

    public func remove(downloadedFile file: DownloadedFile) throws {
        let url = try file.url()
        try fileManager.removeFile(atPath: url)
    }

    public func existingFileIfAvailable(forExpectedFilename filename: String) -> DownloadedFile? {
        let url = try? fileManager.downloadsDirectory(create: false).appendingPathComponent(filename)
        guard let unwrappedUrl = url, FileManager.default.fileExists(atPath: unwrappedUrl.path) else { return nil }
        return try? DownloadedFile(absolutePath: unwrappedUrl)
    }

    public func getActiveTasks() -> [URLSessionDownloadTask] {
        items.map{ $0.task }.compactMap { $0 }
    }
}

// MARK: - Private

private extension AestheteImplementation {

    func cleanQueueStatisticsIfNeeded() {
        guard items.isEmpty else { return }
        lastError = nil
    }

    func createAndScheduleOperation(forItem item: DownloadItem) {
        let operation = BlockOperation { [weak item] in
            // prevent locking queue
            guard item != nil else { return }
            let semaphore = DispatchSemaphore(value: 0)
            item?.completionBlock = { [weak semaphore] in
                semaphore?.signal()
            }
            item?.resume()
            semaphore.wait()
        }
        group.addAsyncOperation(operation: operation)
        observers.forEach { closures in
            closures.progressDownloadClosure?(item.resource, item.task)
        }
    }

    func remove(downloadItem item: DownloadItem) {
        items.remove { $0 == item }
        if items.isEmpty {
            observers.forEach { closures in
                closures.downloadErrorClosure?(item.resource, item.task, self.lastError)
            }
        }
    }
}

// MARK: - URLSessionTaskDelegate

extension AestheteImplementation: URLSessionTaskDelegate {

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        guard let item = item(forDownloadTask: task) else { return }
        let downloadTask = task as! URLSessionDownloadTask
        observers.forEach { closures in
            closures.downloadErrorClosure?(item.resource, downloadTask, error)
        }
        item.completionBlock?()
        remove(downloadItem: item)
    }
}

// MARK: - URLSessionDownloadDelegate

extension AestheteImplementation: URLSessionDownloadDelegate {

    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard let item = item(forDownloadTask: downloadTask) else { return }
        observers.forEach { closures in
            closures.progressDownloadClosure?(item.resource, downloadTask)
        }
    }

    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        guard let item = item(forDownloadTask: downloadTask) else { return }
        do {
            let newLocation = try item.moveToProperLocation(from: location)
            let file = try DownloadedFile(absolutePath: newLocation)
            observers.forEach { closures in
                closures.downloadFinishedClosure?(item.resource, downloadTask, file)
            }
        } catch let error {
            observers.forEach { closures in
                closures.downloadErrorClosure?(item.resource, downloadTask, error)
            }
        }
        item.completionBlock?()
        remove(downloadItem: item)
    }

    private func item(forDownloadTask task: URLSessionTask) -> DownloadItem? {
        items.first {
            $0.task.taskIdentifier == task.taskIdentifier
            && $0.task.taskDescription == task.taskDescription
        }
    }
}

