//
//  WatchingRepositoriesSpec.swift
//  Tests
//
//  Created by mzp on 2017/08/03.
//  Copyright © 2017 mzp. All rights reserved.
//

import Nimble
import Quick

// swiftlint:disable function_body_length
internal class WatchingRepositoriesSpec: QuickSpec {
    override func spec() {
        var xs: WatchingRepositories!
        let alice_a = RepositoryObject(owner: OwnerObject(login: "alice"), name: "a")
        let alice_b = RepositoryObject(owner: OwnerObject(login: "alice"), name: "b")
        let bob = RepositoryObject(owner: OwnerObject(login: "bob"), name: "a")

        beforeEach {
            xs = WatchingRepositories.shared
            xs.clear()
        }

        describe("count") {
            it("should be empty") {
                expect(xs.count) == 0
            }

            it("returns count of elements") {
                xs.append(alice_a)
                xs.append(alice_b)
                xs.append(bob)
                expect(xs.count) == 3
            }
        }

        describe("append and subscription") {
            it("append in alphabet order") {
                xs.append(bob)
                xs.append(alice_a)
                xs.append(alice_b)

                expect(xs[0]) == alice_a
                expect(xs[1]) == alice_b
                expect(xs[2]) == bob
            }
        }

        describe("clear") {
            it("clears all contents") {
                xs.append(bob)
                xs.append(alice_a)

                xs.clear()

                expect(xs.count) == 0
            }
        }

        describe("serialize") {
            beforeEach {
                xs.append(alice_a)
                xs.append(alice_b)
            }

            it("store data") {
                let ys = WatchingRepositories.shared
                expect(ys.count) == 2
            }
        }

        describe("map") {
            beforeEach {
                xs.append(alice_a)
                xs.append(alice_b)
            }

            it("should be transformed") {
                expect(xs.map { $0.stringValue }) == [
                    "alice/a", "alice/b"
                ]
            }
        }
    }
}
