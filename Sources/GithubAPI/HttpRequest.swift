//
//  HttpRequest.swift
//  OctoEye
//
//  Created by mzp on 2017/07/06.
//  Copyright © 2017 mzp. All rights reserved.
//
import BrightFutures
import Result

internal protocol HttpRequestProtocol {
    func post(url: URL, query: String, accessToken: String) -> Future<Data, AnyError>
}

internal class HttpRequest: HttpRequestProtocol {
    struct Request: Encodable {
        let query: String

        init(query: String) {
            self.query = query
        }
    }

    func post(url: URL, query: String, accessToken: String) -> Future<Data, AnyError> {
        return Future { complete in
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.cachePolicy = .reloadIgnoringLocalCacheData // Avoid 412

            do {
                request.httpBody = try JSONEncoder().encode(Request(query: query))
            } catch let e {
                return complete(.failure(AnyError(e)))
            }

            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    return complete(.failure(AnyError(error)))
                }
                guard let data = data else {
                    return
                }
                complete(.success(data))
            }
            task.resume()
        }
    }
}

internal class MockHttpRequest: HttpRequestProtocol {
    private let future: Future<Data, AnyError>

    init(future: Future<Data, AnyError>) {
        self.future = future
    }

    convenience init(response: String) {
        // swiftlint:disable:next force_unwrapping
        let value = response.data(using: .utf8)!
        self.init(future: Future<Data, AnyError>(value: value))
    }

    func post(url: URL, query: String, accessToken: String) -> Future<Data, AnyError> {
        return future
    }
}
