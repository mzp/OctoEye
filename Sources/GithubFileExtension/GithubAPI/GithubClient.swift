//
//  GithubClient.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/06/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import Foundation
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

    // swiftlint:disable:next force_unwrapping
    private let url: URL = URL(string: "https://api.github.com/graphql")!
    private let token: String

    init(token: String) {
        self.token = token
    }

    func query<T: Decodable>(_ query: Query, onComplete : @escaping (Result<T, AnyError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("bearer \(token)", forHTTPHeaderField: "Authorization")
        request.cachePolicy = .reloadIgnoringLocalCacheData // Avoid 412

        do {
            request.httpBody = try JSONEncoder().encode(Request(query: query.create()))
        } catch let e {
            return onComplete(Result<T, AnyError>.failure(AnyError(e)))
        }

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                return onComplete(Result<T, AnyError>.failure(AnyError(error)))
            }
            guard let data = data else {
                return
            }
            do {
                let response = try JSONDecoder().decode(Response<T>.self, from: data)
                onComplete(.success(response.data))
            } catch let e {
                // swiftlint:disable:next force_unwrapping
                let request = String(data: request.httpBody!, encoding: .utf8) ?? ""
                let response = String(data: data, encoding: .utf8) ?? ""
                NSLog("\(request)\n\(response)")
                onComplete(Result<T, AnyError>.failure(AnyError(e)))
            }
        }
        task.resume()
    }
}
