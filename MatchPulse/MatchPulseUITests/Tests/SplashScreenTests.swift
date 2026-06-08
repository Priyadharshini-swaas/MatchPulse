//
//  SplashScreenTests.swift
//  MatchPulseUITests
//
//  FIX NOTES:
//  - These tests create their own XCUIApplication — they do NOT extend
//    MatchPulseUITestCase so they control their own launch/teardown.
//  - testSplash_tabBarContainsAllExpectedTabs now checks static texts instead
//    of nav bar labels, which is more reliable.
//

import XCTest

final class SplashScreenTests: XCTestCase {

    // MARK: - With UI_TESTING bypass

    func testSplash_withUITestingFlag_immediatelyShowsTabBar() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UI_TESTING", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        defer { app.terminate() }

        XCTAssertTrue(
            app.tabBars.firstMatch.waitForExistence(timeout: 5),
            "TabBar should appear almost immediately when UI_TESTING is active"
        )
    }

    func testSplash_tabBarContainsAllExpectedTabs() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UI_TESTING", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        defer { app.terminate() }

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))

        let expectedTabs = ["Home", "Live", "Team", "Competitions", "Profile"]
        for tab in expectedTabs {
            XCTAssertTrue(
                app.tabBars.buttons[tab].exists,
                "Tab '\(tab)' should be in the tab bar"
            )
        }
    }

    func testSplash_defaultSelectedTab_isHome() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UI_TESTING", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        defer { app.terminate() }

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.tabBars.buttons["Home"].isSelected,
            "Home tab should be selected on launch"
        )
    }

    // MARK: - Without UI_TESTING (normal splash flow)

    func testSplash_withoutFlag_showsTitleText() throws {
        let app = XCUIApplication()
        // No UI_TESTING flag — splash runs normally
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        defer { app.terminate() }

        // Splash title uses both the static text label AND accessibilityIdentifier
        // "splash_title" — either query should work
        let byIdentifier = app.staticTexts["splash_title"]
        let byLabel      = app.staticTexts["MatchPulse"]

        let found = byIdentifier.waitForExistence(timeout: 3)
                 || byLabel.waitForExistence(timeout: 1)

        XCTAssertTrue(found,
                      "Splash title 'MatchPulse' should be visible during launch animation")
    }

    func testSplash_withoutFlag_transitionsToHomeScreen() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        defer { app.terminate() }

        // Splash delay is ~2.5 s — allow up to 7 s for safety
        XCTAssertTrue(
            app.tabBars.firstMatch.waitForExistence(timeout: 7),
            "App should transition from splash to HomeScreen within 7 seconds"
        )
    }
}
