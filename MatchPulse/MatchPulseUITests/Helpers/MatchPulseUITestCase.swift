//
//  MatchPulseUITestCase.swift
//  MatchPulseUITests
//
//  Base class shared by every XCUITest file.
//  Handles launch, splash bypass, and shared helper utilities.
//

import XCTest

// MARK: - Base Test Case

class MatchPulseUITestCase: XCTestCase {

    var app: XCUIApplication!

    // MARK: - Setup / Teardown

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments += [
            "UI_TESTING",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US"
        ]
        app.launch()

        // Wait until the tab bar is visible — splash is bypassed
        XCTAssertTrue(
            app.tabBars.firstMatch.waitForExistence(timeout: 8),
            "Tab bar should appear immediately after UI_TESTING splash bypass"
        )
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - Nav Title Helpers
    // All main tabs use .principal toolbar Text (NOT .navigationTitle).
    // The correct XCUITest query is app.staticTexts["nav_title_X"].
    // Only "Match Details" uses .navigationTitle and can use navigationBars["Match Details"].

    func waitForNavTitle(_ identifier: String, timeout: TimeInterval = 6) -> Bool {
        app.staticTexts[identifier].waitForExistence(timeout: timeout)
    }

    func assertNavTitle(_ identifier: String, timeout: TimeInterval = 6,
                        _ message: String = "") {
        let msg = message.isEmpty
            ? "Nav title '\(identifier)' should be visible"
            : message
        XCTAssertTrue(waitForNavTitle(identifier, timeout: timeout), msg)
    }

    // MARK: - Tab Navigation

    func tapTab(_ label: String) {
        let btn = app.tabBars.buttons[label]
        XCTAssertTrue(btn.waitForExistence(timeout: 5), "Tab '\(label)' should exist")
        btn.tap()
    }

    // MARK: - Content Load Wait

    func waitForContentLoaded(timeout: TimeInterval = 15) {
        Thread.sleep(forTimeInterval: 0.6)
    }

    // MARK: - Valid Screen State
    // Checks that a screen shows at least one of: content, empty state,
    // offline-no-cache view, or error view. Call after waitForContentLoaded.

    func assertValidScreenState(
        contentIdentifiers: [String] = [],
        timeout: TimeInterval = 15
    ) {
        let standardStates = ["empty_state_view", "no_cache_offline_view", "error_view"]
        let all = contentIdentifiers + standardStates

        let deadline = Date().addingTimeInterval(timeout)
        var found = false
        while Date() < deadline {
            for id in all {
                if app.otherElements[id].exists { found = true ; break }
            }
            if found { break }
            Thread.sleep(forTimeInterval: 0.5)
        }
        XCTAssertTrue(found,
            "Screen must show one of: \(all.joined(separator: ", "))")
    }

    // MARK: - Back Navigation
    // Safe back-button tap that works regardless of nav bar title.

    func tapBackButton() {
        let navBar = app.navigationBars.firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 5), "Navigation bar must exist to tap back")
        navBar.buttons.firstMatch.tap()
    }
}
