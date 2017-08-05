//
//  TreeObjectSpec.swift
//  Tests
//
//  Created by mzp on 2017/08/05.
//  Copyright © 2017 mzp. All rights reserved.
//

import Nimble
import Quick

internal class TreeObjectSpec: QuickSpec {
    override func spec() {
        describe("RepositoryObject") {
            let repo = RepositoryObject(owner: OwnerObject(login: "mzp"), name: "OctoEye")

            it("serialize to object") {
                expect(repo.stringValue) == "mzp/OctoEye"
            }

            it("parse string value") {
                expect(RepositoryObject(identifier: "mzp/OctoEye")) == repo
            }
        }
    }
}
