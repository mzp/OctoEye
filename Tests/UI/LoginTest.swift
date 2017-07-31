//
//  UI.swift
//  UI
//
//  Created by mzp on 2017/07/31.
//  Copyright © 2017 mzp. All rights reserved.
//

import XCTest

internal class LoginTest: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["clearAccessToken"]
        app.launch()
    }

    public func testLoginForm() {
        let app = XCUIApplication()
        let loginButton = app.buttons["login"]
        XCTAssert(loginButton.exists)
    }
}
