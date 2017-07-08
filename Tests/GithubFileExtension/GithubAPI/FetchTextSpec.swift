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

internal class FetchTextSpec: QuickSpec {
    override func spec() {
        let github = GithubClient(token: "-", httpRequest: MockHttpRequest(response: response))
        let text = forcedFuture { _ in
            FetchText(github: github).call(owner: "mzp", name: "LoveLiver", oid: "-")
        }.value

        describe("text") {
            it("returns file content") {
                expect(text) == "# Xcode (from gitignore.io)"
            }
        }
    }

    private let response: String = """
{
  "data": {
    "repository": {
      "object": {
        "text": "# Xcode (from gitignore.io)"
      }
    }
  }
}
"""
}
