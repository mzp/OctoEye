//
//  FleItemIdentifierSpec.swift
//  Tests
//
//  Created by mzp on 2017/09/06.
//  Copyright © 2017 mzp. All rights reserved.
//

import Nimble
import Quick

internal class FileItemIdentifierSpec: QuickSpec {
    override func spec() {
        let xs: [FileItemIdentifier] = [
            .root,
            .repository(owner: "mzp", name: "OctoEye"),
            .entry(owner: "mzp", name: "OctoEye", oid: "baz", path: ["foo", "bar"])
        ]

        for x in xs {
            describe("\(x)") {
                it("serialize to string") {
                    let y = FileItemIdentifier.parse(x.identifer)
                    expect(y) == x
                }
            }
        }

        describe("join") {
            it("joins with repository") {
                let x = FileItemIdentifier.repository(owner: "mzp", name: "OctoEye")
                expect(x.join(oid: "foo", filename: "bar")) == .entry(
                    owner: "mzp",
                    name: "OctoEye",
                    oid: "foo",
                    path: ["bar"]
                )
            }

            it("joins with entry") {
                let x = FileItemIdentifier.entry(owner: "mzp", name: "OctoEye", oid: "foo", path: ["path"])
                expect(x.join(oid: "bar", filename: "to")) == .entry(
                    owner: "mzp",
                    name: "OctoEye",
                    oid: "bar",
                    path: ["path", "to"]
                )
            }
        }
    }
}
