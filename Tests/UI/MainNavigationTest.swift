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
        let cells = app.tables.cells
        let count4 = NSPredicate(format: "count == 4")
        wait(for: [expectation(for: count4, evaluatedWith: cells, handler: nil)], timeout: 5)
        let repositocyCell = app.tables.cells.containing(.staticText, identifier: "mzp/OctoEye").element
        XCTAssert(repositocyCell.exists)
        repositocyCell.tap()

        // repositories page will appear
        XCTAssert(app.navigationBars["Repositories"].exists)
        let cell = app.tables.cells.containing(.staticText, identifier: "mzp/OctoEye").element
        XCTAssert(cell.exists)

        // remove repositories
        cell.swipeLeft()
        cell.buttons.element(boundBy: 0).tap()
        XCTAssert(!cell.exists)
    }

    func testPaging() {
        let app = XCUIApplication()

        // tap add button
        let addButton = app.navigationBars.buttons["Add"]
        XCTAssert(addButton.exists)
        addButton.tap()

        // add repository page will appear
        XCTAssert(app.navigationBars["Add repository"].exists)

        // paging
        let cells = app.tables.cells
        let count4 = NSPredicate(format: "count == 4")
        let count8 = NSPredicate(format: "count == 8")

        wait(for: [expectation(for: count4, evaluatedWith: cells, handler: nil)], timeout: 5)

        app.tables.cells.containing(.staticText, identifier: "mzp/OctoEye").element.swipeUp()

        wait(for: [expectation(for: count8, evaluatedWith: cells, handler: nil)], timeout: 5)
    }
}
