//
//  DownloadResourceProtocol.swift
//  Aesthete IOS
//
//  Created by Alexander Lezya on 09.11.2021.
//

// MARK: - DownloadResourceProtocol

public protocol DownloadResourceProtocol {

    // MARK: - Properties

    /// Identifier of downloaded resource
    var id: String { get }

    /// Source from which file will be downloaded
    var source: URL? { get }

    /// Preferred destination name (might be different if using `newFile` mode)
    var destinationName: String { get }

    /// Downloading mode: newFile - always create new file even if exist for particular filename, notDownloadIfExist - reuse downloaded files
    var mode: DownloadMode { get }

    /// Attributes applied to downloaded file
    var attributes: [FileAttributeKey: Any]? { get }
}
