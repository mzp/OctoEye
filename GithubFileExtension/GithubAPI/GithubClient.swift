//
//  GithubClient.swift
//  GithubFileExtension
//
//  Created by mzp on 2017/06/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import Foundation
import GraphQLicious

class GithubClient {
    struct Request : Encodable {
        let query : String

        init(query : String) {
            self.query = query
        }
    }

    struct Response<T : Decodable> : Decodable {
        let data : T
    }

    private let url = URL(string: "https://api.github.com/graphql")!
    private let token : String

    init(token: String) {
        self.token = token
    }

    func query<T : Decodable>(_ query: Query, onComplete : @escaping (T?, Error?) -> ()) throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("bearer \(token)", forHTTPHeaderField: "Authorization")

        request.httpBody = try JSONEncoder().encode(Request(query: query.create()))
        request.cachePolicy = .reloadIgnoringLocalCacheData // Avoid 412

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                return onComplete(nil, error)
            }
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(Response<T>.self, from: data)
                onComplete(response.data, nil)
            } catch let e {
                onComplete(nil, e)
            }
        }
        task.resume()
    }
}
