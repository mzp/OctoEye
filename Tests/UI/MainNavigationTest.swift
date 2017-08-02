//
//  MainNavigationTest.swift
//  UITest
//
//  Created by mzp on 2017/07/31.
//  Copyright © 2017 mzp. All rights reserved.
//

import XCTest

internal class MainNavigationTest: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["setAccessToken"]
        app.launchEnvironment["httpResponse"] = fixture(name: "viewerRepositories", ofType: "json")
        app.launch()
    }

    func testMainNavigation() {
        let app = XCUIApplication()

        // it has navigationbar and tabBar
        XCTAssert(app.navigationBars.element.exists)
        XCTAssert(app.tabBars.element.exists)

        // Repositories tab is selected
        XCTAssert(app.navigationBars["Repositories"].exists)

        // Switch to Preferences
        app.tabBars.buttons["Preferences"].tap()
        XCTAssert(app.navigationBars["Preferences"].exists)

        // Switch to Repositories
        app.tabBars.buttons["Repositories"].tap()
        XCTAssert(app.navigationBars["Repositories"].exists)
    }

    func testAddRepository() {
        let app = XCUIApplication()

        // tap add button
        let addButton = app.navigationBars.buttons["Add"]
        XCTAssert(addButton.exists)
        addButton.tap()

        // add repository page will appear
        XCTAssert(app.navigationBars["Add repository"].exists)

        // tap some repository
        let repositocyCell = app.tables.cells.containing(.staticText, identifier: "mzp/OctoEye").element
        XCTAssert(repositocyCell.exists)
        repositocyCell.tap()

        // repositories page will appear
        XCTAssert(app.navigationBars["Repositories"].exists)
    }
}
