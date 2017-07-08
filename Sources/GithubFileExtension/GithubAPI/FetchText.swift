//
//  FetchText.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/07/02.
//  Copyright © 2017 mzp. All rights reserved.
//

import BrightFutures
import GraphQLicious
import Result

internal class FetchText {
    struct Blob: Codable {
        let text: String
    }
    struct Repository: Codable {
        let object: Blob
    }
    struct Response: Codable {
        let repository: Repository
    }

    private let github: GithubClient

    init(github: GithubClient) {
        self.github = github
    }

    func call(owner: String, name: String, oid: String) -> Future<String, AnyError> {
        return github.query(query(owner: owner, name: name, oid: oid)).map { (response: Response) in
            response.repository.object.text
        }
    }

    private func query(owner: String, name: String, oid: String) -> Query {
        return Query(
            request: Request(
                name: "repository",
                arguments: [
                    Argument(key: "owner", values: [owner]),
                    Argument(key: "name", values: [name])
                    ],
                fields: [
                    Request(
                        name: "object",
                        arguments: [ Argument(key: "oid", values: [oid])],
                        fields: ["...blob"]
                    )]),
            fragments: [
                Fragment(withAlias: "blob", name: "Blob", fields: [
                    "text"
                ])
            ]
        )
    }
}
