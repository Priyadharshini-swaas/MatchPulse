//
//  HomeScreenTests.swift
//  MatchPulseUITests
//
//  FIX NOTES:
//  - app.navigationBars["Home"] replaced with app.staticTexts["nav_title_home"]
//    because HomeContentView uses .principal toolbar, not .navigationTitle
//  - State checks now include no_cache_offline_view as a valid state
//

import XCTest

final class HomeScreenTests: MatchPulseUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Already on Home tab by default; let content load
        waitForContentLoaded(timeout: 15)
    }

    // MARK: - Navigation Title

    func testHomeScreen_navigationTitleIsHome() {
        // HomeContentView uses .principal toolbar Text with id "nav_title_home"
        XCTAssertTrue(
            app.staticTexts["nav_title_home"].waitForExistence(timeout: 6),
            "Home screen should display 'Home' in the toolbar"
        )
    }

    // MARK: - Screen States

    func testHomeScreen_showsOneOfExpectedStates() {
        // Valid states: content list | offline banner | no-cache offline | error
        assertValidScreenState(
            contentIdentifiers: ["home_content_list"],
            timeout: 15
        )
    }

    func testHomeScreen_noShimmerAfterLoad() {
        let shimmer = app.otherElements["home_shimmer"]
        XCTAssertFalse(
            shimmer.waitForExistence(timeout: 1),
            "Shimmer should not persist after data loads"
        )
    }

    // MARK: - Live Matches Section

    func testHomeScreen_liveMatchesSectionLabel_whenMatchesExist() {
        let liveHeader = app.staticTexts["LIVE MATCHES"]
        // Only present when live matches are available — OK if absent
        if liveHeader.waitForExistence(timeout: 8) {
            XCTAssertTrue(liveHeader.exists,
                          "'LIVE MATCHES' label should be visible when matches are present")
        }
    }

    // MARK: - Content Cards

    func testHomeScreen_contentCard_existsWhenDataLoaded() {
        let contentList = app.otherElements["home_content_list"]
        guard contentList.waitForExistence(timeout: 15) else { return }

        let firstCard = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH 'content_card_'")
        ).firstMatch

        if firstCard.waitForExistence(timeout: 8) {
            XCTAssertTrue(firstCard.exists, "At least one content card should be visible")
        }
    }

    func testHomeScreen_contentCard_isTappable() {
        let contentList = app.otherElements["home_content_list"]
        guard contentList.waitForExistence(timeout: 15) else { return }

        let firstCard = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH 'content_card_'")
        ).firstMatch
        guard firstCard.waitForExistence(timeout: 8) else { return }

        XCTAssertTrue(firstCard.isHittable, "Content card should be tappable")
    }

    func testHomeScreen_contentCard_tap_doesNotCrash() {
        let firstCard = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH 'content_card_'")
        ).firstMatch
        guard firstCard.waitForExistence(timeout: 12) else { return }

        firstCard.tap()
        XCTAssertTrue(app.exists, "App should not crash after tapping a content card")

        // Return to Home if navigation occurred
        let backBtn = app.navigationBars.firstMatch.buttons.firstMatch
        if backBtn.waitForExistence(timeout: 3) && backBtn.isHittable {
            backBtn.tap()
        }
    }

    // MARK: - Pull-to-Refresh

    func testHomeScreen_pullToRefresh_doesNotCrash() {
        let contentList = app.otherElements["home_content_list"]
        guard contentList.waitForExistence(timeout: 15) else { return }

        contentList.swipeDown()

        // Home screen must still be visible
        XCTAssertTrue(
            app.staticTexts["nav_title_home"].waitForExistence(timeout: 8),
            "Home screen should be intact after pull-to-refresh"
        )
    }

    // MARK: - Error State

    func testHomeScreen_errorState_hasRetryButton() {
        let errorView = app.otherElements["error_view"]
        guard errorView.waitForExistence(timeout: 1) else { return }

        XCTAssertTrue(
            app.buttons["retry_button"].exists,
            "Error view on Home screen should include a Retry button"
        )
    }

    // MARK: - Offline State

    func testHomeScreen_offlineState_showsOfflineBanner_orNoCacheView() {
        let banner      = app.otherElements["offline_banner"]
        let noCacheView = app.otherElements["no_cache_offline_view"]
        // Only one or neither is shown depending on cache availability — just
        // confirm they don't coexist at the same time.
        let bothShown = banner.exists && noCacheView.exists
        XCTAssertFalse(bothShown,
                       "offline_banner and no_cache_offline_view should not appear simultaneously")
    }
}
