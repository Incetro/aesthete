//
//  DownloadedFile.swift
//  Aesthete IOS
//
//  Created by Alexander Lezya on 09.11.2021.
//

import Foundation

// MARK: - DownloadedFile

public struct DownloadedFile {

    // MARK: - Properties

    /// Relative path that should be stored
    public let relativePath: String

    // MARK: - Initializers

    /// Default initializer from URL
    /// - Parameter path: absolute path
    init(absolutePath path: URL) throws {
        let documentsUrl = try FileManager
            .default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        relativePath = String(path.path.replacingOccurrences(of: documentsUrl.path, with: "").dropFirst())
    }

    /// Default initializer from relative path
    /// - Parameter relativePath: relative path
    public init(relativePath: String) {
        self.relativePath = relativePath
    }

    // MARK: - Useful

    /// Getter for url of file
    public func url() throws -> URL {
        try FileManager
            .default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(relativePath)
    }
}

// MARK: - Equatable

extension DownloadedFile: Equatable {

    public static func == (lhs: DownloadedFile, rhs: DownloadedFile) -> Bool {
        lhs.relativePath == rhs.relativePath
    }
}

