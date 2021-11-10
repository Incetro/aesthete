//
//  AestheteConfiguration.swift
//  Aesthete IOS
//
//  Created by Alexander Lezya on 09.11.2021.
//

// MARK: - AestheteConfiguration

public struct AestheteConfiguration {

    // MARK: - Properties

    /// Downloading mode serial / parallel
    public let mode: Mode

    /// Base queue of operations
    public let queue: OperationQueue

    /// Base downloads directory name, i.e. "this-property-value/your-file-name.png"
    public let baseDownloadsDirectoryName: String

    /// Default configuration is parallel up to 25 tasks
    public static var `default`: AestheteConfiguration {
        AestheteConfiguration(mode: .parallel(max: 25))
    }

    // MARK: - Initializers

    /// Default initializer
    /// - Parameters:
    ///   - mode: download mode
    ///   - queue: Operation queue
    ///   - baseDownloadsDirectoryName: base downloads directory name
    public init(
        mode: Mode,
        queue: OperationQueue = OperationQueue(),
        baseDownloadsDirectoryName: String = "Downloads"
    ) {
        self.mode = mode
        self.queue = queue
        self.baseDownloadsDirectoryName = baseDownloadsDirectoryName
    }

    // MARK: - Useful

    func limitedGroup() -> LimitedOperationGroup {
        switch mode {
        case .serial:
            return LimitedOperationGroup(limit: 1)
        case .parallel(let limit):
            return LimitedOperationGroup(limit: limit)
        }
    }
}

