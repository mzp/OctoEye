//
//  FetchTextSpec.swift
//  Tests
//
//  Created by mzp on 2017/07/07.
//  Copyright © 2017 mzp. All rights reserved.
//

import JetToTheFuture
import Nimble
import Quick
import Result

internal class FetchBlobSpec: QuickSpec {
    override func spec() {
        let github = GithubClient(
            token: "-",
            httpRequest: MockHttpRequest(response: fixture(name: "content", ofType: "txt")))
        let data = forcedFuture { _ in
            FetchBlob(github: github).call(owner: "octocat", name: "example", oid: "-")
        }.value
        // swiftlint:disable:next force_unwrapping
        let text = String(data: data!, encoding: String.Encoding.utf8)

        describe("text") {
            it("returns file content") {
                expect(text) == "Content of the blob\n"
            }
        }
    }
}
