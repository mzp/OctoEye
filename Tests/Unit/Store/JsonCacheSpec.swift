//
//  JsonCacheSpec.swift
//  Tests
//
//  Created by mzp on 2017/09/03.
//  Copyright © 2017 mzp. All rights reserved.
//

import Nimble
import Quick

// swiftlint:disable function_body_length, force_try
internal class JsonCacheSpec: QuickSpec {

    override func spec() {
        var cache: JsonCache<String>!

        describe("save and fetch") {
            beforeEach {
                JsonCache<String>.clearAll()
                cache = JsonCache<String>(name: "quick")
            }

            it("store root entries") {
                try! cache.store(parent: [], entries: [
                    "tmp": "temp dir",
                    "etc": "etc dir"
                ])

                expect(cache[["tmp"]]) == "temp dir"
                expect(cache[["etc"]]) == "etc dir"
            }

            it("store sub entries") {
                try! cache.store(parent: [], entries: [
                    "tmp": "temp dir"
                ])
                try! cache.store(parent: ["tmp"], entries: [
                    "a": "file a"
                ])
                expect(cache[["tmp", "a"]]) == "file a"
            }

            it("store sub sub entries") {
                try! cache.store(parent: ["tmp"], entries: [
                    "a": "file a"
                    ])
                expect(cache[["tmp", "a"]]) == "file a"
            }
        }
    }
}
