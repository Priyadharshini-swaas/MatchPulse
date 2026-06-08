//
//  ProfileTests.swift
//  MatchPulseUITests
//
//  FIX NOTES:
//  - app.navigationBars["Profile"] replaced with app.staticTexts["nav_title_profile"]
//    (ProfilePlaceholderView uses .principal toolbar, not .navigationTitle)
//

import XCTest

final class ProfileTests: MatchPulseUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        tapTab("Profile")
    }

    // MARK: - Navigation Title

    func testProfileScreen_navigationTitleIsProfile() {
        // ProfilePlaceholderView uses .principal toolbar Text("Profile")
        // identified by nav_title_profile
        XCTAssertTrue(
            app.staticTexts["nav_title_profile"].waitForExistence(timeout: 5),
            "Profile tab should display 'Profile' in the toolbar"
        )
    }

    // MARK: - Content

    func testProfileScreen_profileTitleTextExists() {
        let title = app.staticTexts["profile_title"]
        XCTAssertTrue(
            title.waitForExistence(timeout: 5),
            "'Profile' label should be visible on the Profile screen"
        )
        XCTAssertEqual(title.label, "Profile")
    }

    func testProfileScreen_comingSoonTextExists() {
        let comingSoon = app.staticTexts["profile_coming_soon"]
        XCTAssertTrue(
            comingSoon.waitForExistence(timeout: 5),
            "'Coming Soon' label should be visible on the Profile screen"
        )
        XCTAssertEqual(comingSoon.label, "Coming Soon")
    }

    // MARK: - Tab State

    func testProfileTab_isSelectedAfterTap() {
        XCTAssertTrue(
            app.tabBars.buttons["Profile"].isSelected,
            "Profile tab should be selected"
        )
    }

    func testProfileTab_switchAway_thenBack_retainsState() {
        tapTab("Home")
        XCTAssertFalse(app.tabBars.buttons["Profile"].isSelected)

        tapTab("Profile")
        XCTAssertTrue(app.tabBars.buttons["Profile"].isSelected)

        // Toolbar title and content should still be present
        XCTAssertTrue(
            app.staticTexts["nav_title_profile"].waitForExistence(timeout: 5),
            "Profile nav title should reappear after switching back"
        )
        XCTAssertTrue(
            app.staticTexts["profile_coming_soon"].waitForExistence(timeout: 5),
            "Profile content should still be visible after switching back"
        )
    }
}
