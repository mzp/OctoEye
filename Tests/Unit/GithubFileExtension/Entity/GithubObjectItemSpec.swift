//
//  GithubObjectItemSpec.swift
//  Tests
//
//  Created by mzp on 2017/07/07.
//  Copyright © 2017 mzp. All rights reserved.
//

import Nimble
import Quick

internal class GithubObjectItemSpec: QuickSpec {
    override func spec() {
        describe("documentSize") {
            it("return nil") {
                let item = GithubObjectItem()
                item.size = -1
                expect(item.documentSize).to(beNil())
            }

            it("return some size") {
                let item = GithubObjectItem()
                item.size = 42
                expect(item.documentSize) == 42
            }
        }
    }
}
