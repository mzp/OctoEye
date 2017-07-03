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

class FetchChildItems {
    struct Response : Codable {
        struct Repository : Codable {
            let object : TreeObject
        }
        let repository : Repository
    }

    private let github : GithubClient

    init(github : GithubClient) {
        self.github = github
    }

    func call(owner : String, name : String, oid : String, onComplete : @escaping (Result<[EntryObject], AnyError>) -> ()) {
        github.query(query(owner: owner, name: name, oid: oid)) { (result : Result<Response, AnyError>) in
            onComplete(result.map {
                $0.repository.object.entries
            })
        }
    }

    private func query(owner : String, name : String, oid : String) -> Query {
        return Query(
            request: Request(
                name: "repository",
                arguments: [
                    Argument(key: "owner", values: [owner]),
                    Argument(key: "name", values: [name]),
                    ],
                fields: [
                    Request(
                        name: "object",
                        arguments: [ Argument(key: "oid", values: [oid])],
                        fields: ["...\(TreeObject.fragmentName)"]
                    )]),
            fragments: TreeObject.fragments)
    }
}
