//
//  DownloadsFileManagerProtocol.swift
//  Aesthete IOS
//
//  Created by Alexander Lezya on 09.11.2021.
//

import Foundation

// MARK: - DownloadsFileManagerProtocol

protocol DownloadsFileManagerProtocol: AnyObject {

    /// Returns download directory
    /// - Returns: URL path
    func downloadsDirectory(create: Bool) throws -> URL

    /// Move target resource to target URL path
    func move(fromPath source: URL, toPath destination: URL, resource: DownloadResource) throws

    /// Clean download directory
    func cleanDownloadsDirectory() throws

    /// Remove file from given path
    func removeFile(atPath path: URL) throws

    /// Create URL for name
    /// - Returns: URL path
    func createUrl(forName name: String, unique: Bool) throws -> URL
}
