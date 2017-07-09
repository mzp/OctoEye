//
//  PreferencesSpec.swift
//  Tests
//
//  Created by mzp on 2017/07/10.
//  Copyright © 2017 mzp. All rights reserved.
//

import Nimble
import Quick

internal class PreferencesSpec: QuickSpec {
    override func spec() {
        describe("accessToken") {
            it("save value") {
                Preferences.accessToken = "some-token"
                expect(Preferences.accessToken) == "some-token"
            }
        }
    }
}
