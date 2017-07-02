//
//  FetchEntries.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/07/01.
//  Copyright © 2017 mzp. All rights reserved.
//

import Foundation
import GraphQLicious
import Result

class FetchRootItems {
    struct Response : Codable {
        struct Target : Codable {
            let tree : TreeObject
        }
        struct Ref : Codable {
            let target : Target
        }
        struct Repository : Codable {
            let defaultBranchRef : Ref
        }
        let repository : Repository
    }

    private let github : GithubClient

    init(github : GithubClient) {
        self.github = github
    }

    func call(owner : String, name : String, parentItemIdentifier: NSFileProviderItemIdentifier, onComplete : @escaping (Result<[FileItem], AnyError>) -> ()) {
        github.query(query(owner: owner, name : name)) { (result : Result<Response, AnyError>) in
            onComplete(result.map {
                $0.repository.defaultBranchRef.target.tree.entries.map {
                    FileItem(
                        owner: owner,
                        name: name,
                        oid: $0.oid,
                        filename: $0.name,
                        type: $0.type,
                        parentItemIdentifier: parentItemIdentifier
                    )
                }
            })
        }
    }

    private func query(owner : String, name : String) -> Query {
        return Query(
            request: Request(
                name: "repository",
                arguments: [
                    Argument(key: "owner", values: [owner]),
                    Argument(key: "name", values: [name]),
                    ],
                fields: [
                    Request(
                        name: "defaultBranchRef",
                        fields: [
                            Request(name: "target", fields: ["...commit"])
                        ])]),
            fragments: [
                Fragment(withAlias: "commit", name: "Commit", fields: [
                    Request(name: "tree", fields: [
                        "...\(TreeObject.fragmentName)"
                    ])
                ]),
                TreeObject.fragment
            ])
    }
}
