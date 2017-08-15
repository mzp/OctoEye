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
    func get(url: URL, accessToken: String) -> Future<Data, AnyError>
    func post(url: URL, query: String, accessToken: String) -> Future<Data, AnyError>
}

internal class HttpRequest: HttpRequestProtocol {
    struct Request: Encodable {
        let query: String

        init(query: String) {
            self.query = query
        }
    }

    func get(url: URL, accessToken: String) -> Future<Data, AnyError> {
        return request(url: url, accessToken: accessToken) {
            $0.httpMethod = "GET"
            $0.addValue("application/vnd.github.v3.raw", forHTTPHeaderField: "Accept")
        }
    }

    func post(url: URL, query: String, accessToken: String) -> Future<Data, AnyError> {
        return request(url: url, accessToken: accessToken) {
            $0.httpMethod = "POST"
            $0.httpBody = try JSONEncoder().encode(Request(query: query))
        }
    }

    private func request(url: URL,
                         accessToken: String,
                         builder: (inout URLRequest) throws -> Void) -> Future<Data, AnyError> {
        return Future { complete in
            var request = URLRequest(url: url)
            request.addValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.cachePolicy = .reloadIgnoringLocalCacheData // Avoid 412

            do {
                try builder(&request)
            } catch let error {
                return complete(.failure(AnyError(error)))
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

    func get(url: URL, accessToken: String) -> Future<Data, AnyError> {
        return future
    }

    func post(url: URL, query: String, accessToken: String) -> Future<Data, AnyError> {
        return future
    }
}
