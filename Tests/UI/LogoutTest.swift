//
//  LogoutTest.swift
//  UITest
//
//  Created by mzp on 2017/07/31.
//  Copyright © 2017 mzp. All rights reserved.
//

import XCTest

internal class LogoutTest: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["setAccessToken"]
        app.launch()
    }

    public func testLogoutForm() {
        let app = XCUIApplication()

        // switch to preferences page
        app.tabBars.buttons["Preferences"].tap()

        // show logout button, and not show login button
        XCTAssert(!app.buttons["login"].exists)
        let logoutCell = app.tables.cells.containing(.staticText, identifier: "Logout").element
        XCTAssert(logoutCell.exists)

        // if tap logout button, login screen will show
        logoutCell.tap()
        XCTAssert(app.buttons["login"].exists)
    }
}
