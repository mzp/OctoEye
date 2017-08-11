//
//  SearchRepositoryTest.swift
//  Tests
//
//  Created by mzp on 2017/08/11.
//  Copyright © 2017 mzp. All rights reserved.
//

import XCTest

internal class SearchRepositoryTest: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["setAccessToken"]
        app.launchEnvironment["httpResponse"] = fixture(name: "viewerRepositories-last", ofType: "json")
        app.launchEnvironment["httpResponse_later"] = fixture(name: "searchRepositories", ofType: "json")
        app.launch()
    }

    func testSearchRepository() {
        let app = XCUIApplication()

        // tap add button
        let addButton = app.navigationBars.buttons["Add"]
        XCTAssert(addButton.exists)
        addButton.tap()

        // add repository page will appear
        XCTAssert(app.navigationBars["Add repository"].exists)

        // show search bar
        app.swipeDown()
        app.searchFields.element(boundBy: 0).tap()
        app.typeText("apple")

        // wait for throttle
        sleep(1)

        // select repository
        let cell = app.tables.cells.containing(.staticText, identifier: "apple/swift").element
        XCTAssert(cell.exists)
        cell.tap()

        // selected repository appears
        XCTAssert(app.navigationBars["Repositories"].exists)
        XCTAssert(cell.exists)
    }
}
