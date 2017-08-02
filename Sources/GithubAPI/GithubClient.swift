//
//  GithubClient.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/06/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import BrightFutures
import GraphQLicious
import Result

internal class GithubClient {
    struct Request: Encodable {
        let query: String

        init(query: String) {
            self.query = query
        }
    }

    struct Response<T: Decodable> : Decodable {
        let data: T
    }

    static var shared: GithubClient? {
        if Mock.enabled {
            return GithubClient(token: "", httpRequest: MockHttpRequest(response: Mock.httpResponse()))
        } else {
            return Authentication.accessToken.map {
                GithubClient(token: $0)
            }
        }
    }

    // swiftlint:disable:next force_unwrapping
    private let url: URL = URL(string: "https://api.github.com/graphql")!
    private let token: String
    private let httpRequest: HttpRequestProtocol

    init(token: String, httpRequest: HttpRequestProtocol = HttpRequest()) {
        self.token = token
        self.httpRequest = httpRequest
    }

    func query<T: Decodable>(_ query: Query) -> Future<T, AnyError> {
        return httpRequest
            .post(url: url, query: query.create(), accessToken: token)
            .flatMap { data in
                Result {
                    let response = try JSONDecoder().decode(Response<T>.self, from: data)
                    return response.data
                }
            }
    }
}
