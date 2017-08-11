//
//  SearchRepositoriesSpec.swift
//  Tests
//
//  Created by mzp on 2017/08/11.
//  Copyright © 2017 mzp. All rights reserved.
//

import JetToTheFuture
import Nimble
import Quick
import Result

internal class SearchhRepositoriesSpec: QuickSpec {
    override func spec() {
        let github = GithubClient(
            token: "-",
            httpRequest: MockHttpRequest(response: fixture(name: "searchRepositories", ofType: "json")))

        let value = forcedFuture {
            SearchRepositories(github: github).call(query: "")
        }.value

        describe("repositories") {
            it("has repositories") {
                expect(value?.0).to(haveCount(10))
            }
        }
        describe("cursor") {
            it("has next cursor") {
                expect(value?.1).toNot(beNil())
            }
        }
    }
}
