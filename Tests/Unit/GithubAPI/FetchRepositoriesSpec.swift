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
    private func fetch(
        _ name: String,
        _ cursor: FetchRepositories.Cursor? = nil
    ) -> ([RepositoryObject], FetchRepositories.Cursor?) {
        let github = GithubClient(
            token: "-",
            httpRequest: MockHttpRequest(response: fixture(name: name, ofType: "json")))

        return forcedFuture { _ in
            FetchRepositories(github: github).call(after: cursor)
        // swiftlint:disable:next force_unwrapping
        }.value!
    }

    override func spec() {
        // swiftlint:disable:next force_unwrapping
        var repositories: [RepositoryObject]!
        var cursor: FetchRepositories.Cursor?

        describe("first page") {
            context("has next") {
                beforeEach {
                    let value = self.fetch("viewerRepositories")
                    repositories = value.0
                    cursor = value.1
                }

                it("returns file content") {
                    expect(repositories).to(haveCount(4))
                }

                it("contains repository") {
                    expect(repositories?[0].owner.login) == "mzp"
                    expect(repositories?[0].name) == "OctoEye"
                }

                it("has next") {
                    expect(cursor) == "Y3Vyc29yOnYyOpHOAAUwdg=="
                }
            }

            context("has not next") {
                beforeEach {
                    let value = self.fetch("viewerRepositories-last")
                    repositories = value.0
                    cursor = value.1
                }

                it("returns file content") {
                    expect(repositories).to(haveCount(4))
                }

                it("contains repository") {
                    expect(repositories?[0].owner.login) == "mzp"
                    expect(repositories?[0].name) == "OctoEye"
                }

                it("has next") {
                    expect(cursor).to(beNil())
                }
            }
        }

        describe("paging") {
            context("has next") {
                beforeEach {
                    let value = self.fetch("viewerRepositories", "foo")
                    repositories = value.0
                    cursor = value.1
                }

                it("returns file content") {
                    expect(repositories).to(haveCount(4))
                }
            }
        }
    }
}
