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

    public func testWalkThrought() {
        let app = XCUIApplication()

        assertPageTitle("Empower Files with Github")
        app.swipeLeft()

        assertPageTitle("Add favorited repositories")
        app.swipeLeft()

        assertPageTitle("Github location is available")
        app.swipeLeft()

        let loginButton = app.buttons["login"]
        XCTAssert(loginButton.exists)
    }

    public func testSkipButton() {
        let app = XCUIApplication()

        app.buttons["Skip"].tap()

        let loginButton = app.buttons["login"]
        XCTAssert(loginButton.exists)
    }

    private func assertPageTitle(_ title: String) {
        let app = XCUIApplication()
        let window = app.windows.element(boundBy: 0)

        let predicate = NSPredicate(format: "label contains '\(title)'")
        let element = app.buttons.containing(predicate).element
        XCTAssert(element.exists)
        XCTAssert(window.frame.contains(element.frame))

    }
}
