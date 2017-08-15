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

internal class FetchBlob {
    private let github: GithubClient

    init(github: GithubClient) {
        self.github = github
    }

    func call(owner: String, name: String, oid: String) -> Future<Data, AnyError> {
        return github.get("/repos/\(owner)/\(name)/git/blobs/\(oid)")
    }
}
