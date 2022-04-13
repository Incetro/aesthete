//
//  ConcurrentArray.swift
//  Aesthete IOS
//
//  Created by Alexander Lezya on 09.11.2021.
//

import Foundation

// MARK: - ConcurrentArray

final class ConcurrentArray<T: Equatable> {

    // MARK: - Properties

    /// Concurrent queue
    private let queue = DispatchQueue(label: "com.aesthete.management.queue", attributes: .concurrent)

    /// Array of cuncurrent
    private var array = [T]()

    /// Array element count
    var count: Int {
        queue.sync { self.array.count }
    }

    /// True if array is empty
    var isEmpty: Bool {
        queue.sync { self.array.isEmpty }
    }
}

// MARK: - ConcurrentArrayProtocol

extension ConcurrentArray: ConcurrentArrayProtocol {

    typealias DownloadItem = T

    subscript(index: Int) -> T? {
        get {
            queue.sync {
                guard self.array.startIndex..<self.array.endIndex ~= index else { return nil }
                return self.array[index]
            }
        }
        set {
            guard let newValue = newValue else { return }
            queue.async(flags: .barrier) {
                self.array[index] = newValue
            }
        }
    }

    func first(where predicate: (T) -> Bool) -> T? {
        queue.sync { self.array.first(where: predicate) }
    }

    func filter(_ isIncluded: (T) -> Bool) -> [T] {
        queue.sync { self.array.filter(isIncluded) }
    }

    func index(where predicate: (T) -> Bool) -> Int? {
        queue.sync { self.array.firstIndex(where: predicate) }
    }

    func map<ElementOfResult>(_ transform: (T) -> ElementOfResult) -> [ElementOfResult] {
        queue.sync { self.array.map(transform) }
    }

    func forEach(_ body: (T) -> Void) {
        queue.sync { self.array.forEach(body) }
    }

    func contains(where predicate: (T) -> Bool) -> Bool {
        queue.sync { self.array.contains(where: predicate) }
    }

    func append(_ element: T) {
        queue.async(flags: .barrier) { self.array.append(element) }
    }

    func remove(where predicate: @escaping (T) -> Bool) {
        queue.async(flags: .barrier) {
            guard let index = self.array.firstIndex(where: predicate) else { return }
            self.array.remove(at: index)
        }
    }

    func removeAll() {
        queue.async(flags: .barrier) { self.array.removeAll() }
    }

    func contains(_ element: T) -> Bool {
        queue.sync { self.array.contains(element) }
    }
}
