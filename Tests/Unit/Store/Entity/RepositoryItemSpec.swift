//
//  RepositoryItemSpec.swift
//  Tests
//
//  Created by mzp on 2017/07/07.
//  Copyright © 2017 mzp. All rights reserved.
//

import Nimble
import Quick

internal class RepositoryItemSpec: QuickSpec {
    override func spec() {
        let item = RepositoryItem(owner: "mzp", name: "OctoEye")

        describe("item") {
            describe("item identifier") {
                it("constructs item identifier") {
                    expect(item.itemIdentifier) == NSFileProviderItemIdentifier("repository.mzp.OctoEye")
                }
                it("has root identifier as parent") {
                    expect(item.parentItemIdentifier) == NSFileProviderItemIdentifier.rootContainer
                }
            }

            describe("filename") {
                it("constructs filename") {
                    expect(item.filename) == "mzp/OctoEye"
                }
            }

            describe("static fields") {
                it("has folder type") {
                    expect(item.typeIdentifier) == "public.folder"
                }
            }
        }
    }
}
