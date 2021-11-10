//
//  ConcurrentArrayProtocol.swift
//  Aesthete IOS
//
//  Created by Alexander Lezya on 09.11.2021.
//

// MARK: - ConcurrentArrayProtocol

protocol ConcurrentArrayProtocol {

    // MARK: - Associated types

    associatedtype DownloadItem where DownloadItem: Equatable

    // MARK: - Subscripts

    /// Return item at the give index
    subscript(index: Int) -> DownloadItem? { get set }

    /// Returns the first item of the sequence that satisfies the given predicate
    /// - Returns: DownloadItem instance
    func first(where predicate: (DownloadItem) -> Bool) -> DownloadItem?

    /// Returns the items of the sequence that included given item
    /// - Returns: array of DownloadItem
    func filter(_ isIncluded: (DownloadItem) -> Bool) -> [DownloadItem]

    /// Returns the first index in which item of the collection satisfies the given predicate
    /// - Returns: index
    func index(where predicate: (DownloadItem) -> Bool) -> Int?

    /// Returns an array containing the results of mapping the given closure over the sequence’s items
    /// - Returns: array of DownloadItem
    func map<ElementOfResult>(_ transform: (DownloadItem) -> ElementOfResult) -> [ElementOfResult]

    /// Calls the given closure on each element in the sequence in the same order as a for-in loop
    func forEach(_ body: (DownloadItem) -> Void)

    /// Returns a Boolean value indicating whether the sequence contains item that satisfies the given predicate
    /// - Returns: boolean result
    func contains(where predicate: (DownloadItem) -> Bool) -> Bool

    /// Adds a new item at the end of the array
    func append( _ element: DownloadItem)

    /// Removes and returns the item that satisfies the given predicate at the specified position
    func remove(where predicate: @escaping (DownloadItem) -> Bool)

    /// Removes all items from the array
    func removeAll()

    /// Returns a Boolean value indicating whether the sequence contains the given item
    /// - Returns: bolean result
    func contains(_ element: DownloadItem) -> Bool
}
