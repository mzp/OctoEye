//
//  AuthenticationSpec.swift
//  Tests
//
//  Created by mzp on 2017/07/10.
//  Copyright © 2017 mzp. All rights reserved.
//

import Nimble
import Quick

internal class AuthenticationSpec: QuickSpec {
    override func spec() {
        describe("accessToken") {
            it("save value") {
                Authentication.accessToken = "some-token"
                expect(Authentication.accessToken) == "some-token"
            }
        }
    }
}
