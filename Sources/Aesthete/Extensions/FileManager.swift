//
//  FileManager.swift
//  Aesthete IOS
//
//  Created by Alexander Lezya on 09.11.2021.
//

import Foundation

// MARK: - FileManager

public extension FileManager {

    /// Append path for given resource with name and configuration
    /// - Parameters:
    ///   - name: resource name
    ///   - configuration: AestheteConfiguration instance
    /// - Returns: URL
    static func aesthetePath(
        forResourceWithName name: String,
        usingConfiguration configuration: AestheteConfiguration = AestheteConfiguration.default
    ) -> URL? {
        let fileManager = DownloadsFileManager(withBaseDownloadsDirectoryName: configuration.baseDownloadsDirectoryName)
        guard let downloads = try? fileManager.downloadsDirectory() else { return nil }
        let path = downloads.appendingPathComponent(name)
        guard FileManager.default.fileExists(atPath: path.path) else { return nil }
        return path
    }
}
