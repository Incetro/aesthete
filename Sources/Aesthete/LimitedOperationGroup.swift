//
//  LimitedOperationGroup.swift
//  Aesthete IOS
//
//  Created by Alexander Lezya on 09.11.2021.
//

// MARK: - LimitedOperationGroup

/// It's just a simple wrapper around OperationQueue for making extensions later and prevent
/// containing two operation queues in one class
final class LimitedOperationGroup {

    // MARK: - Properties

    /// Queue used only for scheduling tasks
    let queue: OperationQueue

    /// Max concurrent operation count
    let limit: Int

    // MARK: - Initializers

    /// Default initializer
    /// - Parameter limit: max concurrent operation count
    init(limit: Int = 1) {
        self.queue = OperationQueue()
        queue.maxConcurrentOperationCount = limit
        self.limit = limit
    }

    // MARK: - Useful

    /// Add async operation
    /// - Parameter operation: Operation instance
    func addAsyncOperation(operation: Operation) {
        queue.addOperation(operation)
    }
}
