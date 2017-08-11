//
//  TreeObject.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/07/02.
//  Copyright © 2017 mzp. All rights reserved.
//

import Foundation
import GraphQLicious

internal struct BlobObject: Codable {
    let byteSize: Int?
}

internal struct OwnerObject: Codable {
    let login: String
}

internal struct RepositoryObject: Codable {
    let owner: OwnerObject
    let name: String

    var stringValue: String {
        return "\(owner.login)/\(name)"
    }

    init(owner: OwnerObject, name: String) {
        self.owner = owner
        self.name = name
    }

    init?(identifier: String) {
        let xs = identifier.components(separatedBy: "/")
        if xs.count != 2 {
            return nil
        }
        self.init(owner: OwnerObject(login: xs[0]), name: xs[1])
    }

    static let fragment: Fragment = Fragment(withAlias: "repository", name: "Repository", fields: [
        Request(name: "owner", fields: ["login"]),
        "name"
    ])
}

internal struct EntryObject: Codable {
    let repository: RepositoryObject
    let oid: String
    let name: String
    let type: String
    let object: BlobObject
}

internal struct TreeObject: Codable {
    let entries: [EntryObject]

    static let fragmentName: String = "tree"
    static let fragments: [Fragment] = [
        Fragment(withAlias: "blob", name: "Blob", fields: [ "byteSize" ]),
        Fragment(withAlias: fragmentName, name: "Tree", fields: [
            Request(name: "entries", fields: [
                "oid",
                "name",
                "type",
                Request(name: "object", fields: [ "...blob" ]),
                Request(name: "repository", fields: [
                    Request(name: "owner", fields: ["login"]),
                    "name"
                    ])
                ])
            ])
    ]
}

internal struct PageInfoObject: Codable {
    let endCursor: String?
    let hasNextPage: Bool

    static let fragment: Fragment = Fragment(withAlias: "pageInfo", name: "PageInfo", fields: [
        "endCursor",
        "hasNextPage"
    ])
}

// MARK: Equatable
extension OwnerObject: Equatable {}
internal func == (lhs: OwnerObject, rhs: OwnerObject) -> Bool {
    return lhs.login == rhs.login
}

extension RepositoryObject: Equatable {}
internal func == (lhs: RepositoryObject, rhs: RepositoryObject) -> Bool {
    return lhs.owner == rhs.owner && lhs.name == rhs.name
}

// MARK: Comparable
extension OwnerObject: Comparable {
    static func < (lhs: OwnerObject, rhs: OwnerObject) -> Bool {
        return lhs.login < rhs.login
    }
}
extension RepositoryObject: Comparable {
    static func < (lhs: RepositoryObject, rhs: RepositoryObject) -> Bool {
        return (lhs.owner < rhs.owner) || (lhs.owner == rhs.owner && lhs.name < rhs.name)
    }
}
