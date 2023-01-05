//
//  Stockroom.swift
//  
//
//  Created by Toomas Vahter on 05.01.2023.
//

import Foundation

/// A persistent store for data.
public actor Stockroom {
    
    // MARK: - Creating the Stockroom
    
    /// The name of the stockroom.
    public let name: String
    
    private let url: URL
    
    /// Creates a stockroom with the given name.
    public init(name: String) throws {
        self.name = name
        self.url = URL.documentsDirectory.appendingPathComponent(name)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    // MARK: - Loading and Storing Data
    
    private func url(for identifier: String) -> URL {
        url.appending(path: identifier.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    /// Load data on disk and transform it.
    /// - Parameters:
    ///   - identifier: An identifier of the data.
    ///   - dataTransformer: Transforms data to a specified type.
    /// - Returns: A value for the transformed data.
    public func load<T>(for identifier: String, dataTransformer: @escaping (Data) -> T?) async -> T? {
        let url = self.url(for: identifier)
        guard FileManager.default.fileExists(atPath: url.path()) else { return nil }
        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            return dataTransformer(data)
        }
        catch {
            print("Failed reading data at URL \(url).")
            return nil
        }
    }
    
    /// Store data on disk.
    /// - Parameters:
    ///   - provider: A block providing the data running on a background thread.
    ///   - identifier: An identifier to use when storing the data.
    /// - Returns: An identifier used for storing the data.
    public func store(_ provider: @escaping () -> Data?, for identifier: String = UUID().uuidString) async throws -> String {
        let url = self.url(for: identifier)
        guard let data = provider(), !data.isEmpty else {
            throw StockroomError.noDataToStore
        }
        try data.write(to: url, options: .atomic)
        return identifier
    }
    
    // MARK: -
    
    /// Load data on disk.
    /// - Parameters:
    ///   - identifier: An identifier of the data.
    /// - Returns: The data on disk for the specified identifier.
    public func loadData(for identifier: String) async -> Data? {
        await load(for: identifier, dataTransformer: { $0 })
    }
    
    /// Store data on disk.
    /// - Parameters:
    ///   - data: The data to store.
    ///   - identifier: An identifier to use when storing the data.
    /// - Returns: An identifier used for storing the data.
    public func storeData(_ data: Data, for identifier: String = UUID().uuidString) async throws -> String {
        try await store({ data }, for: identifier)
    }
    
    // MARK: - Removing Data
    
    /// Removes data stored on disk.
    /// - Parameter identifier: The identifier of the data.
    public func removeData(for identifier: String) throws {
        let url = self.url(for: identifier)
        guard FileManager.default.fileExists(atPath: url.path()) else { return }
        try FileManager.default.removeItem(at: url)
    }
    
    /// Removes all the data on disk.
    public func removeAll() throws {
        let urls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        try urls.forEach({ try FileManager.default.removeItem(at: $0) })
    }
}

/// Errors thrown by Stockroom.
public enum StockroomError: Error {
    /// The data provider did not return any data for storing.
    case noDataToStore
}
