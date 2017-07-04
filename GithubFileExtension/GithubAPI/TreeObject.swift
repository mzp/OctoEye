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
