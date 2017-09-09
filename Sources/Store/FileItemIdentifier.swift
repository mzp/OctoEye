//
//  FileItemIdentifier.swift
//  OctoEye
//
//  Created by mzp on 2017/09/06.
//  Copyright © 2017 mzp. All rights reserved.
//

import FileProvider

internal enum FileItemIdentifier: Equatable {
    static func == (lhs: FileItemIdentifier, rhs: FileItemIdentifier) -> Bool {
        switch (lhs, rhs) {
        case (.root, .root):
            return true
        case (.repository(owner: let owner1, name: let name1), .repository(owner: let owner2, name: let name2)):
            return owner1 == owner2 && name1 == name2
        case (.entry(owner: let owner1, name: let name1, oid: let oid1, path: let path1),
              .entry(owner: let owner2, name: let name2, oid: let oid2, path: let path2)):
            return owner1 == owner2 && name1 == name2 && oid1 == oid2 && path1 == path2
        default:
            return false
        }
    }

    case root
    case repository(owner: String, name: String)
    case entry(owner: String, name: String, oid: String, path: [String])

    static func parse(_ identifer: NSFileProviderItemIdentifier) -> FileItemIdentifier? {
        if identifer == NSFileProviderItemIdentifier.rootContainer {
            return .root
        } else {
            let xs = identifer.rawValue.components(separatedBy: ".")
            switch xs.first ?? "" {
            case "repository":
                return .repository(owner: xs[1], name: xs[2])
            case "entry":
                return .entry(owner: xs[1], name: xs[2], oid: xs[3], path: Array(xs.dropFirst(4)))
            default:
                return nil
            }
        }
    }

    var identifer: NSFileProviderItemIdentifier {
        switch self {
        case .root:
            return NSFileProviderItemIdentifier.rootContainer
        case .repository(owner: let owner, name: let name):
            return NSFileProviderItemIdentifier(rawValue: "repository.\(owner).\(name)")
        case .entry(owner: let owner, name: let name, let oid, path: let path):
            return NSFileProviderItemIdentifier(
                rawValue: "entry.\(owner).\(name).\(oid).\(path.joined(separator: "."))"
            )
        }
    }

    func join(oid: String, filename: String) -> FileItemIdentifier? {
        switch self {
        case .root:
            return nil
        case .repository(owner: let owner, name: let name):
            return .entry(owner: owner, name: name, oid: oid, path: [filename])
        case .entry(owner: let owner, name: let name, oid: _, path: let path):
            return .entry(owner: owner, name: name, oid: oid, path: path + [filename])
        }
    }
}
