//
//  AestheteObserving.swift
//  Aesthete IOS
//
//  Created by Alexander Lezya on 10.11.2021.
//

import Foundation

// MARK: - Aliases

public typealias ProgressDownloadClosure = (_ resource: DownloadResource, _ task: URLSessionDownloadTask) -> Void

public typealias DownloadFinishedClosure = (_ resource: DownloadResource, _ task: URLSessionDownloadTask, _ downloadedFile: DownloadedFile) -> Void

public typealias DownloadErrorClosure = (_ resource: DownloadResource, _ task: URLSessionDownloadTask, _ error: Error?) -> Void

// MARK: - AestheteObserving

public struct AestheteObserving {

    // MARK: - Properties

    /// Progress doownload closure
    let progressDownloadClosure: ProgressDownloadClosure?

    /// Download finished closure
    let downloadFinishedClosure: DownloadFinishedClosure?

    /// Download error closure
    let downloadErrorClosure: DownloadErrorClosure?

    // MARK: - Initializers

    public init(
        progressDownloadClosure: ProgressDownloadClosure? = nil,
        downloadFinishedClosure: DownloadFinishedClosure? = nil,
        downloadErrorClosure: DownloadErrorClosure? = nil
    ) {
        self.progressDownloadClosure = progressDownloadClosure
        self.downloadFinishedClosure = downloadFinishedClosure
        self.downloadErrorClosure = downloadErrorClosure
    }
}
