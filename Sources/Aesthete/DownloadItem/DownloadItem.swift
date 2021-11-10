//
//  DownloadItem.swift
//  Aesthete IOS
//
//  Created by Alexander Lezya on 09.11.2021.
//

// MARK: - DownloadItem

final class DownloadItem {

    // MARK: - Properties

    /// DownloadResource instance
    let resource: DownloadResource

    /// DownloadsFileManagerProtocol instance
    weak var fileManager: DownloadsFileManagerProtocol?

    /// Internal indicate that task is finished
    var completionBlock: (() -> Void)?

    /// URLSessionDownloadTask instance
    let task: URLSessionDownloadTask

    /// True if resource moved
    private(set) var completed = false

    // MARK: - Initialzers

    /// Ddefault initializer
    /// - Parameters:
    ///   - resource: DownloadResource instance
    ///   - fileManager: DownloadsFileManagerProtocol instance
    ///   - session: URLSession instance
    init(
        resource: DownloadResource,
        fileManager: DownloadsFileManagerProtocol,
        session: URLSession
    ) throws {
        self.resource = resource
        self.fileManager = fileManager
        guard let downloadUrl = resource.source else { throw DownloadError.missingURL }
        let task = session.downloadTask(with: downloadUrl)
        task.taskDescription = resource.id
        self.task = task
    }

    func cancel() {
        task.cancel()
        completionBlock?()
    }

    func resume() {
        task.resume()
    }

    func moveToProperLocation(from location: URL) throws -> URL {
        let destination = try path(forResource: resource)
        try fileManager?.move(fromPath: location, toPath: destination, resource: resource)
        completed = true
        return destination
    }

    func path(forResource resource: DownloadResource) throws -> URL {
        switch resource.mode {
        case .newFile:
            return try fileManager.unsafelyUnwrapped.createUrl(forName: resource.destinationName, unique: true)
        case .notDownloadIfExists:
            return try fileManager.unsafelyUnwrapped.createUrl(forName: resource.destinationName, unique: false)
        }
    }
}

// MARK: - Equatable

extension DownloadItem: Equatable {

    static func == (lhs: DownloadItem, rhs: DownloadItem) -> Bool {
        return lhs.resource == rhs.resource
            && lhs.task == rhs.task
    }
}

