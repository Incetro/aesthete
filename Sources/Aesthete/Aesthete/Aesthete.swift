//
//  Aesthete.swift
//  Aesthete IOS
//
//  Created by Alexander Lezya on 10.11.2021.
//

import Foundation

// MARK: - Aesthete

public protocol Aesthete {

    /// Need to add observer
    func add(observer: AnyObject, closures: AestheteObserving)

    /// Need to remove observer
    func remove(observer: AnyObject)

    /// Schedule multiple downloads
    /// - Parameter resources: Resources to download
    func enqueueMultipleDownloads(forResources resources: [DownloadResource]) throws

    /// Add new download to Cedric's queue
    /// - Parameter resource: resource to be downloaded
    func enqueueDownload(forResource resource: DownloadResource) throws

    /// Cancel downloading resources with id
    /// - Parameter id: identifier of resource to be cancel (please not that there might be multiple resources with the same identifier, all of them will be canceled)
    func cancel(downloadingResourcesWithId id: String)

    /// Cancel all running downloads
    func cancelAllDownloads()

    /// Returns download task for state observing
    /// - Parameter resource: Resource related with task (if using newFile mode first matching task is returned)
    /// - Returns: URLSessionDownloadTask for observing state / progress
    func downloadTask(forResource resource: DownloadResource) -> URLSessionDownloadTask?

    /// Returns download task for state observing
    /// - Parameter resourceId: Id of resource related with task (if using newFile mode first matching task is returned)
    /// - Returns: URLSessionDownloadTask for observing state / progress
    func downloadTask(forResourceWithId resourceId: String) -> URLSessionDownloadTask?

    /// Check is aesthete currently downloading resource with particular id
    /// - Parameter id: Unique id of resource
    func isDownloading(resourceWithId id: String) -> Bool

    /// Remove all files downloaded by Aesthete
    /// - Throws: Exceptions occured while removing files
    func cleanDownloadsDirectory() throws

    /// Remove particular file
    /// - Parameter file: File to remove
    /// - Throws: Exceptions occured while removing file
    func remove(downloadedFile file: DownloadedFile) throws

    /// Get file for expected filename
    /// - Parameter filename: expected filename
    /// - Returns: DownloadedFile object if file exists at path
    func existingFileIfAvailable(forExpectedFilename filename: String) -> DownloadedFile?

    /// Return active tasks
    /// - Returns: Currently under operation tasks
    func getActiveTasks() -> [URLSessionDownloadTask]
}
