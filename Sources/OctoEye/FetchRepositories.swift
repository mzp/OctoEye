//
//  FetchRepositories.swift
//  OctoEye
//
//  Created by mzp on 2017/08/01.
//  Copyright © 2017 mzp. All rights reserved.
//

import BrightFutures
import GraphQLicious
import Result

internal class InputObject: ArgumentValue {
    private let values: [String:String]

    init(_ values: [String:String]) {
        self.values = values
    }

    public var asGraphQLArgument: String {
        let fields = values.map { (key, value) in "\(key): \(value)" }
        return "{\(fields.joined(separator: ","))}"
    }
}

internal class FetchRepositories {
    struct Repositories: Codable {
        let nodes: [RepositoryObject]
    }
    struct Viewer: Codable {
        let repositories: Repositories
    }
    struct Response: Codable {
        let viewer: Viewer
    }

    private let github: GithubClient

    init(github: GithubClient) {
        self.github = github
    }

    func call() -> Future<[RepositoryObject], AnyError> {
        return github.query(query()).map { (response: Response) in
            response.viewer.repositories.nodes
        }
    }

    private func query() -> Query {
        return Query(
            request: Request(
                name: "viewer",
                arguments: [],
                fields: [
                    Request(name: "repositories",
                            arguments: [
                                Argument(key: "first", value: 10),
                                Argument(key: "orderBy", value: InputObject([
                                    "field": "PUSHED_AT",
                                    "direction": "DESC"
                                ]))
                            ],
                            fields: [
                                Request(name: "nodes", fields: [
                                    Request(name: "repository", fields: [
                                        "id",
                                        Request(name: "owner", fields: ["login"]),
                                        "name"
                                    ])
                                ])
                            ])
                ])
            )
    }
}
