//
//  FetchEntries.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/07/01.
//  Copyright © 2017 mzp. All rights reserved.
//

import BrightFutures
import GraphQLicious
import Result

internal class FetchRootItems {
    struct Target: Codable {
        let tree: TreeObject
    }
    struct Ref: Codable {
        let target: Target
    }
    struct Repository: Codable {
        let defaultBranchRef: Ref
    }
    struct Response: Codable {
        let repository: Repository
    }

    private let github: GithubClient

    init(github: GithubClient) {
        self.github = github
    }

    func call(owner: String, name: String) -> Future<[EntryObject], AnyError> {
        return github.query(query(owner: owner, name : name)).map { (response: Response) in
            response.repository.defaultBranchRef.target.tree.entries
        }
    }

    private func query(owner: String, name: String) -> Query {
        return Query(
            request: Request(
                name: "repository",
                arguments: [
                    Argument(key: "owner", values: [owner]),
                    Argument(key: "name", values: [name])
                    ],
                fields: [
                    Request(
                        name: "defaultBranchRef",
                        fields: [
                            Request(name: "target", fields: ["...commit"])
                        ])]),
            fragments: Array([
                [Fragment(withAlias: "commit", name: "Commit", fields: [
                    Request(name: "tree", fields: [
                        "...\(TreeObject.fragmentName)"
                        ])
                ])],
                TreeObject.fragments
            ].joined()))
    }
}
