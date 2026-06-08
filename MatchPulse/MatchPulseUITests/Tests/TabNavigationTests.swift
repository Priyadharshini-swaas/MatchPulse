//
//  TabNavigationTests.swift
//  MatchPulseUITests
//
//  Verifies tab-bar navigation across all five tabs.
//
//  FIX NOTES:
//  All main tabs use .principal toolbar Text views, NOT .navigationTitle.
//  XCUITest's navigationBars["X"] only matches .navigationTitle("X").
//  Correct pattern: app.staticTexts["nav_title_X"].waitForExistence(...)
//

import XCTest

final class TabNavigationTests: MatchPulseUITestCase {

    // MARK: - Tab Bar Existence

    func testTabBar_isVisibleOnLaunch() {
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Tab bar must be visible")
    }

    func testTabBar_hasFiveButtons() {
        // TabView with 5 items produces exactly 5 tab bar buttons on iOS
        let count = app.tabBars.firstMatch.buttons.count
        XCTAssertEqual(count, 5, "Tab bar should have exactly 5 tabs, found \(count)")
    }

    // MARK: - Home Tab

    func testHomeTab_isSelectedByDefault() {
        XCTAssertTrue(
            app.tabBars.buttons["Home"].isSelected,
            "Home should be the default selected tab on launch"
        )
    }

    func testHomeTab_showsNavTitle() {
        tapTab("Home")
        // HomeContentView uses .principal toolbar with nav_title_home identifier
        XCTAssertTrue(
            app.staticTexts["nav_title_home"].waitForExistence(timeout: 6),
            "Home tab should show 'Home' title in toolbar"
        )
    }

    // MARK: - Live Tab

    func testLiveTab_canBeTapped() {
        tapTab("Live")
        XCTAssertTrue(
            app.tabBars.buttons["Live"].isSelected,
            "Live tab should be selected after tap"
        )
    }

    func testLiveTab_showsNavTitle() {
        tapTab("Live")
        // MatchesView uses .principal toolbar with nav_title_live identifier
        XCTAssertTrue(
            app.staticTexts["nav_title_live"].waitForExistence(timeout: 6),
            "Live tab should show 'Live' title in toolbar"
        )
    }

    func testLiveTab_showsContentOrEmptyState() {
        tapTab("Live")
        assertValidScreenState(
            contentIdentifiers: ["match_list", "live_screen"],
            timeout: 15
        )
    }

    // MARK: - Team Tab

    func testTeamTab_canBeTapped() {
        tapTab("Team")
        XCTAssertTrue(
            app.tabBars.buttons["Team"].isSelected,
            "Team tab should be selected after tap"
        )
    }

    func testTeamTab_showsNavTitle() {
        tapTab("Team")
        // TeamSliderView uses .principal toolbar with nav_title_teams identifier
        XCTAssertTrue(
            app.staticTexts["nav_title_teams"].waitForExistence(timeout: 6),
            "Team tab should show 'Teams' title in toolbar"
        )
    }

    // MARK: - Competitions Tab

    func testCompetitionsTab_canBeTapped() {
        tapTab("Competitions")
        XCTAssertTrue(
            app.tabBars.buttons["Competitions"].isSelected,
            "Competitions tab should be selected after tap"
        )
    }

    func testCompetitionsTab_showsNavTitle() {
        tapTab("Competitions")
        // CompetitionGridView uses .principal toolbar with nav_title_competitions identifier
        XCTAssertTrue(
            app.staticTexts["nav_title_competitions"].waitForExistence(timeout: 6),
            "Competitions tab should show 'Competitions' title in toolbar"
        )
    }

    func testCompetitionsTab_showsContentOrEmptyState() {
        tapTab("Competitions")
        assertValidScreenState(
            contentIdentifiers: ["competitions_grid", "competitions_screen"],
            timeout: 15
        )
    }

    // MARK: - Profile Tab

    func testProfileTab_canBeTapped() {
        tapTab("Profile")
        XCTAssertTrue(
            app.tabBars.buttons["Profile"].isSelected,
            "Profile tab should be selected after tap"
        )
    }

    func testProfileTab_showsNavTitle() {
        tapTab("Profile")
        // ProfilePlaceholderView uses .principal toolbar with nav_title_profile identifier
        XCTAssertTrue(
            app.staticTexts["nav_title_profile"].waitForExistence(timeout: 5),
            "Profile tab should show 'Profile' title in toolbar"
        )
    }

    func testProfileTab_showsComingSoonText() {
        tapTab("Profile")
        XCTAssertTrue(
            app.staticTexts["profile_coming_soon"].waitForExistence(timeout: 5),
            "Profile should show 'Coming Soon' placeholder text"
        )
    }

    // MARK: - Round-Trip Navigation

    func testTabSwitching_homeToLiveToHome() {
        XCTAssertTrue(app.tabBars.buttons["Home"].isSelected)

        tapTab("Live")
        XCTAssertTrue(app.tabBars.buttons["Live"].isSelected)
        XCTAssertFalse(app.tabBars.buttons["Home"].isSelected)

        tapTab("Home")
        XCTAssertTrue(app.tabBars.buttons["Home"].isSelected)
        XCTAssertFalse(app.tabBars.buttons["Live"].isSelected)
    }

    func testTabSwitching_allTabsSequentially() {
        let tabs = ["Home", "Live", "Team", "Competitions", "Profile"]
        for tab in tabs {
            tapTab(tab)
            XCTAssertTrue(
                app.tabBars.buttons[tab].isSelected,
                "After tapping '\(tab)' it should be selected"
            )
        }
    }

    func testTabSwitching_profileToHomeAndBack() {
        tapTab("Profile")
        XCTAssertTrue(app.tabBars.buttons["Profile"].isSelected)

        tapTab("Home")
        XCTAssertTrue(app.tabBars.buttons["Home"].isSelected)

        tapTab("Profile")
        XCTAssertTrue(app.tabBars.buttons["Profile"].isSelected)
        // Profile content must still be there
        XCTAssertTrue(
            app.staticTexts["profile_coming_soon"].waitForExistence(timeout: 3)
        )
    }
}
