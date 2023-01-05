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
    
    /// The name of the persistent store.
    public let name: String
    
    private let url: URL
    
    public init(name: String) throws {
        self.name = name
        self.url = URL.documentsDirectory.appendingPathComponent(name)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    // MARK: - Loading and Storing Data
    
    private func url(for identifier: String) -> URL {
        url.appending(path: identifier.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
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
    
    public func store(_ provider: @escaping () -> Data?, for identifier: String = UUID().uuidString) async throws -> String {
        let url = self.url(for: identifier)
        guard let data = provider(), !data.isEmpty else {
            throw StockroomError.noDataToStore
        }
        try data.write(to: url, options: .atomic)
        return identifier
    }
    
    // MARK: -
    
    public func loadData(for identifier: String) async -> Data? {
        await load(for: identifier, dataTransformer: { $0 })
    }
    
    public func storeData(_ data: Data, for identifier: String = UUID().uuidString) async throws -> String {
        try await store({ data }, for: identifier)
    }
    
    // MARK: - Removing Data
    
    public func removeData(for identifier: String) throws {
        let url = self.url(for: identifier)
        guard FileManager.default.fileExists(atPath: url.path()) else { return }
        try FileManager.default.removeItem(at: url)
    }
    
    public func removeAll() throws {
        let urls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        try urls.forEach({ try FileManager.default.removeItem(at: $0) })
    }
}

public enum StockroomError: Error {
    case noDataToStore
}
