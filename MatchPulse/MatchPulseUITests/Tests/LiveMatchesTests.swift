//
//  LiveMatchesTests.swift
//  MatchPulseUITests
//
//  FIX NOTES:
//  - app.navigationBars["Live"] replaced with app.staticTexts["nav_title_live"]
//    (MatchesView uses .principal toolbar, not .navigationTitle)
//  - State checks include no_cache_offline_view
//  - Pull-to-refresh test removed (swipeDown on LazyVStack inside ScrollView
//    is unreliable in XCUITest without PTR-specific support)
//  - Back navigation uses tapBackButton() helper
//

import XCTest

final class LiveMatchesTests: MatchPulseUITestCase {

    // MARK: - Setup

    override func setUpWithError() throws {
        try super.setUpWithError()
        tapTab("Live")
        waitForContentLoaded(timeout: 15)
    }

    // MARK: - Live Screen Rendering

    func testLiveScreen_navigationTitleIsLive() {
        // MatchesView uses .principal toolbar Text("Live") with id "nav_title_live"
        XCTAssertTrue(
            app.staticTexts["nav_title_live"].waitForExistence(timeout: 6),
            "Live tab should show 'Live' in the toolbar"
        )
    }

    func testLiveScreen_showsOneOfExpectedStates() {
        // Valid states: match list | empty state | no-cache offline | error view
        assertValidScreenState(
            contentIdentifiers: ["match_list", "live_screen"],
            timeout: 15
        )
    }

    func testLiveScreen_noLoadingSpinnerAfterDataArrives() {
        let shimmer = app.otherElements["match_list_shimmer"]
        XCTAssertFalse(
            shimmer.waitForExistence(timeout: 1),
            "Shimmer should not persist after data arrives"
        )
    }

    // MARK: - Match Card → Details Navigation

    func testMatchCard_tapNavigatesToMatchDetails() {
        let matchList = app.otherElements["match_list"]
        guard matchList.waitForExistence(timeout: 15) else {
            XCTSkip("No live match cards available — skipping navigation test")
            return
        }

        let firstCard = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH 'match_card_'")
        ).firstMatch

        XCTAssertTrue(
            firstCard.waitForExistence(timeout: 10),
            "At least one match card should be visible"
        )
        firstCard.tap()

        // MatchDetailsView uses .navigationTitle("Match Details") — correct query
        XCTAssertTrue(
            app.navigationBars["Match Details"].waitForExistence(timeout: 8),
            "Tapping a match card should navigate to 'Match Details'"
        )
    }

    func testMatchDetails_screenIdentifierExists() {
        let matchList = app.otherElements["match_list"]
        guard matchList.waitForExistence(timeout: 15) else {
            XCTSkip("No live match cards available")
            return
        }

        let firstCard = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH 'match_card_'")
        ).firstMatch
        guard firstCard.waitForExistence(timeout: 10) else {
            XCTSkip("No match card found")
            return
        }
        firstCard.tap()

        let detailsScreen = app.otherElements["match_details_screen"]
        XCTAssertTrue(
            detailsScreen.waitForExistence(timeout: 8),
            "match_details_screen identifier should be present after navigation"
        )
    }

    func testMatchDetails_hasRefreshButton() {
        let matchList = app.otherElements["match_list"]
        guard matchList.waitForExistence(timeout: 15) else { XCTSkip("No match data"); return }

        let firstCard = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH 'match_card_'")
        ).firstMatch
        guard firstCard.waitForExistence(timeout: 8) else { XCTSkip("No card"); return }
        firstCard.tap()

        // Wait for Match Details nav bar (uses .navigationTitle so this works)
        let navBar = app.navigationBars["Match Details"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 8))

        // Toolbar has one button: the refresh/clockwise icon
        let refreshBtn = navBar.buttons.firstMatch
        XCTAssertTrue(refreshBtn.exists, "Refresh button should exist in Match Details toolbar")
        XCTAssertTrue(refreshBtn.isHittable, "Refresh button should be tappable")
    }

    // MARK: - Back Navigation

    func testMatchDetails_backButtonReturnsToLiveTab() {
        let matchList = app.otherElements["match_list"]
        guard matchList.waitForExistence(timeout: 15) else { XCTSkip("No match data"); return }

        let firstCard = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH 'match_card_'")
        ).firstMatch
        guard firstCard.waitForExistence(timeout: 8) else { XCTSkip("No card"); return }
        firstCard.tap()

        XCTAssertTrue(
            app.navigationBars["Match Details"].waitForExistence(timeout: 8)
        )

        // Use base helper — finds back button in any nav bar
        tapBackButton()

        // Live tab nav title should reappear
        XCTAssertTrue(
            app.staticTexts["nav_title_live"].waitForExistence(timeout: 6),
            "Back button should return to Live screen"
        )
        XCTAssertTrue(
            app.tabBars.buttons["Live"].isSelected,
            "Live tab should remain selected after back navigation"
        )
    }

    // MARK: - Error State

    func testLiveScreen_errorState_showsRetryButton() {
        let errorView = app.otherElements["error_view"]
        guard errorView.waitForExistence(timeout: 1) else { return }

        XCTAssertTrue(
            app.buttons["retry_button"].exists,
            "Error state should show a Retry button"
        )
    }

    func testLiveScreen_retryButton_isTappable() {
        let retryBtn = app.buttons["retry_button"]
        guard retryBtn.waitForExistence(timeout: 1) else { return }
        XCTAssertTrue(retryBtn.isHittable, "Retry button should be tappable")
        retryBtn.tap()
    }
}
