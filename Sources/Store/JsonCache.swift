//
//  JsonCache.swift
//  OctoEye
//
//  Created by mzp on 2017/09/03.
//  Copyright © 2017 mzp. All rights reserved.
//

import Ikemen

internal class JsonCache<T: Codable> {
    typealias PathComponent = String
    typealias Path = [PathComponent]

    private class Entry<T: Codable>: Codable {
        let value: T?
        var subentries: [PathComponent:Entry]

        init(value: T?) {
            self.value = value
            self.subentries = [:]
        }
    }

    private let cacheDirectory: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    private let file: URL

    init(name: String) {
        self.file = self.cacheDirectory.appendingPathComponent("\(name).json")
    }

    func store(parent: Path, entries: [PathComponent:T]) throws {
        let subentries = entries.mapValues {
            Entry(value: $0)
        }

        try update { $0 ※ { get(root: $0, path: parent).subentries = subentries } }
    }

    subscript(path: Path) -> T? {
        return get(root: root, path: path).value
    }

    private func get(root: Entry<T>, path: Path) -> Entry<T> {
        return path.reduce(root) { (entry, key) in
            if let x = entry.subentries[key] {
                return x
            } else {
                return Entry(value: nil) ※ {
                    entry.subentries[key] = $0
                }
            }
        }
    }

    private var root: Entry<T> {
        guard let data = try? Data(contentsOf: file) else {
            return Entry(value: nil)
        }
        guard let entry = try? JSONDecoder().decode(Entry<T>.self, from: data) else {
            return Entry(value: nil)
        }
        return entry
    }

    private func update(updater: (Entry<T>) -> Entry<T>) throws {
        try write(root: updater(root))
    }

    private func write(root: Entry<T>) throws {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted

        let data = try jsonEncoder.encode(root)
        try data.write(to: file)
    }

    static func clearAll() {
        let fileManager = FileManager.default
        guard let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }

        let directoryContents = try? fileManager.contentsOfDirectory(
            at: cacheURL,
            includingPropertiesForKeys: nil,
            options: [])
        for file in directoryContents ?? [] {
            try? fileManager.removeItem(at: file)
        }
    }
}
