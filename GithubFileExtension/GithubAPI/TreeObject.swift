//
//  TreeObject.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/07/02.
//  Copyright © 2017 mzp. All rights reserved.
//

import Foundation
import GraphQLicious

struct OwnerObject : Codable {
    let login : String
}

struct RepositoryObject : Codable {
    let owner : OwnerObject
    let name : String
}

struct EntryObject : Codable {
    let repository : RepositoryObject
    let oid : String
    let name : String
    let type : String
}

struct TreeObject : Codable {
    let entries : [EntryObject]

    static let fragmentName = "tree"
    static let fragment =
        Fragment(withAlias: fragmentName, name: "Tree", fields: [
            Request(name: "entries", fields: [
                "oid",
                "name",
                "type",
                Request(name: "repository", fields: [
                    Request(name: "owner", fields: ["login"]),
                    "name"
                    ])
                ])
            ])
}
