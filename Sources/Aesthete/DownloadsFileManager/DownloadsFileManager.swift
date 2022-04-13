//
//  DownloadsFileManager.swift
//  Aesthete IOS
//
//  Created by Alexander Lezya on 09.11.2021.
//

import Foundation

// MARK: - DownloadsFileManager

final class DownloadsFileManager: DownloadsFileManagerProtocol {

    // MARK: - Properties

    /// Base downloads directory name
    let baseDownloadsDirectoryName: String

    // MARK: - Initializers

    /// Default initializer
    /// - Parameter baseDownloadsDirectoryName: base downloads directory name
    init(withBaseDownloadsDirectoryName baseDownloadsDirectoryName: String) {
        self.baseDownloadsDirectoryName = baseDownloadsDirectoryName
    }

    // MARK: - Useful

    func downloadsDirectory(create: Bool = false) throws -> URL {
        try FileManager
            .default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: create)
            .appendingPathComponent(baseDownloadsDirectoryName)
    }

    func createUrl(forName name: String, unique: Bool) throws -> URL {
        let downloads = try downloadsDirectory(create: true)
        try createDownloadsDirectoryIfNeeded()
        if unique {
            return try uniquePath(forName: name)
        } else {
            return downloads.appendingPathComponent(name)
        }
    }

    func move(fromPath source: URL, toPath destination: URL, resource: DownloadResource) throws {
        try FileManager.default.moveItem(at: source, to: destination)
        if let attributes = resource.attributes {
            try FileManager.default.setAttributes(attributes, ofItemAtPath: destination.path)
        }
    }

    func cleanDownloadsDirectory() throws {
        let downloads = try downloadsDirectory()
        let content = try FileManager.default.contentsOfDirectory(atPath: downloads.path)
        try content.forEach({ try FileManager.default.removeItem(atPath: "\(downloads.path)/\($0)")})
    }

    func removeFile(atPath path: URL) throws {
        try FileManager.default.removeItem(atPath: path.path)
    }

    func uniquePath(forName name: String) throws -> URL {
        let downloads = try downloadsDirectory(create: false)
        let basePath = downloads.appendingPathComponent(name)
        let fileExtension = basePath.pathExtension
        let filenameWithoutExtension: String
        if fileExtension.count > 0 {
            filenameWithoutExtension = String(name.dropLast(fileExtension.count + 1))
        } else {
            filenameWithoutExtension = name
        }
        var destinationPath = basePath
        var existing = 0
        while FileManager.default.fileExists(atPath: destinationPath.path) {
            existing += 1
            let newFilenameWithoutExtension = "\(filenameWithoutExtension)(\(existing))"
            destinationPath = downloads.appendingPathComponent(newFilenameWithoutExtension).appendingPathExtension(fileExtension)
        }
        return destinationPath
    }

    func createDownloadsDirectoryIfNeeded() throws {
        let downloads = try downloadsDirectory()
        var isDir: ObjCBool = true
        if FileManager.default.fileExists(atPath: downloads.path, isDirectory: &isDir) == false {
            try FileManager
                .default
                .createDirectory(at: downloads, withIntermediateDirectories: true, attributes: nil)
        }
    }
}

