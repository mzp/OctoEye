//
//  Snapshot.swift
//  Snapshot
//
//  Created by mzp on 2017/09/13.
//  Copyright © 2017 mzp. All rights reserved.
//

import XCTest

internal class SnapshotTest: XCTestCase {
    func testIntro() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments = ["clearAccessToken"]
        app.launch()

        snapshot("01Intro")
    }

    func testPreference() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments = ["setAccessToken"]
        app.launchEnvironment["httpResponse"] = fixture(name: "viewerRepositories-last", ofType: "json")
        app.launchEnvironment["httpResponse_later"] = fixture(name: "searchRepositories", ofType: "json")
        app.launch()

        // tap add button
        app.navigationBars.buttons["Add"].tap()
        snapshot("02AddRepository")

        // show search bar
        app.swipeDown()
        app.searchFields.element(boundBy: 0).tap()
        app.typeText("apple")

        // wait for throttle
        sleep(1)
        snapshot("03Search")
    }

    func testFiles() {
        let octoeye = XCUIApplication()
        octoeye.launch()
        octoeye.terminate()

        let app = XCUIApplication(bundleIdentifier: "com.apple.DocumentsApp")
        setupSnapshot(app)
        app.activate()
        app.tabBars.buttons["Browse"].tap()
        let button = app.navigationBars.buttons["Locations"]
        if button.exists {
            button.tap()
        }
        snapshot("04Location")
    }
}
