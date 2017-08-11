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
    typealias Cursor = String
    struct Repositories: Codable {
        let nodes: [RepositoryObject]
        let pageInfo: PageInfoObject
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

    func call(after: Cursor? = nil) -> Future<([RepositoryObject], Cursor?), AnyError> {
        return github.query(query(after: after)).map { (response: Response) in
            var cursor: Cursor? = nil
            if response.viewer.repositories.pageInfo.hasNextPage {
                cursor = response.viewer.repositories.pageInfo.endCursor
            }
            return (response.viewer.repositories.nodes, cursor)
        }
    }

    private func query(after: Cursor? = nil) -> Query {
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
                            ] + pagingQuery(after: after),
                            fields: [
                                Request(name: "nodes", fields: [
                                    RepositoryObject.fragment
                                ]),
                                Request(name: "pageInfo", fields: [
                                    PageInfoObject.fragment
                                ])
                            ])
                ]),
            fragments: [
                PageInfoObject.fragment,
                RepositoryObject.fragment
            ])
    }

    private func pagingQuery(after: Cursor?) -> [Argument] {
        return after.map { [Argument(key: "after", value: $0)] } ?? []
    }
}
