//
//  File.swift
//  OctoEye
//
//  Created by mzp on 2017/08/11.
//  Copyright © 2017 mzp. All rights reserved.
//

import BrightFutures
import GraphQLicious
import Result

internal class RawValue: ArgumentValue {
    let asGraphQLArgument: String

    init(_ rawValue: String) {
        self.asGraphQLArgument = rawValue
    }
}

internal class SearchRepositories {
    typealias Cursor = String
    struct Repositories: Codable {
        let nodes: [RepositoryObject]
        let pageInfo: PageInfoObject
    }
    struct Response: Codable {
        let search: Repositories
    }

    private let github: GithubClient

    init(github: GithubClient) {
        self.github = github
    }

    func call(query: String, after: Cursor? = nil) -> Future<([RepositoryObject], Cursor?), AnyError> {
        return github.query(makeQuery(query: query, after: after)).map { (response: Response) in
            var cursor: Cursor? = nil
            if response.search.pageInfo.hasNextPage {
                cursor = response.search.pageInfo.endCursor
            }
            return (response.search.nodes, cursor)
        }
    }

    private func makeQuery(query: String, after: Cursor? = nil) -> Query {
        return Query(
            request: Request(
                name: "search",
                arguments: [
                    Argument(key: "first", value: 10),
                    Argument(key: "type", value: RawValue("REPOSITORY")),
                    Argument(key: "query", value: query)
                ] + pagingQuery(after: after),
                fields: [
                    Request(name: "nodes", fields: [
                        RepositoryObject.fragment
                    ]),
                    Request(name: "pageInfo", fields: [
                        PageInfoObject.fragment
                    ])
                ]),
            fragments: [
                PageInfoObject.fragment,
                RepositoryObject.fragment
            ]
        )
    }

    private func pagingQuery(after: Cursor?) -> [Argument] {
        return after.map { [Argument(key: "after", value: $0)] } ?? []
    }
}
