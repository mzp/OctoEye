//
//  FileItemStore.swift
//  OctoEye
//
//  Created by mzp on 2017/09/07.
//  Copyright © 2017 mzp. All rights reserved.
//

import FileProvider

internal class FileItemStore {
    subscript(identifier: FileItemIdentifier) -> GithubObjectItem? {
        switch identifier {
        case .root:
            return nil
        case .repository(owner: _, name: _):
            return nil
        case .entry(owner: let owner, name: let name, oid: _, path: let path):
            return cacheFor(owner: owner, name: name)[path]
        }
    }

    func append(parent: FileItemIdentifier, entries: [String:GithubObjectItem]) throws {
        switch parent {
        case .root:
            ()
        case .repository(owner: let owner, name: let name):
            try cacheFor(owner: owner, name: name).store(parent: [], entries: entries)
        case .entry(owner: let owner, name: let name, oid: _, path: let path):
            try cacheFor(owner: owner, name: name).store(parent: path, entries: entries)
        }
    }

    private func cacheFor(owner: String, name: String) -> JsonCache<GithubObjectItem> {
        return JsonCache(name: "\(owner)-\(name)")
    }
}
