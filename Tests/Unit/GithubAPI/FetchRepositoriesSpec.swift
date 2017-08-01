//
//  FetchRepositoriesSpec.swift
//  Tests
//
//  Created by mzp on 2017/08/01.
//  Copyright © 2017 mzp. All rights reserved.
//

import JetToTheFuture
import Nimble
import Quick
import Result

internal class FetchRepositoriesSpec: QuickSpec {
    override func spec() {
        let github = GithubClient(
            token: "-",
            httpRequest: MockHttpRequest(response: fixture(name: "viewerRepositories", ofType: "json")))
        let repositories = forcedFuture { _ in
            FetchRepositories(github: github).call()
        }.value

        describe("text") {
            it("returns file content") {
                expect(repositories).to(haveCount(4))
            }

            it("contains repository") {
                expect(repositories?[0].owner.login) == "mzp"
                expect(repositories?[0].name) == "OctoEye"
            }
        }
    }
}
