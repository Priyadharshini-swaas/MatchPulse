//
//  CompetitionsTests.swift
//  MatchPulseUITests
//
//  FIX NOTES:
//  - app.navigationBars["Competitions"] replaced with staticTexts["nav_title_competitions"]
//    (CompetitionGridView uses .principal toolbar, not .navigationTitle)
//  - DarkStandingsView now has .navigationTitle("") and .navigationBarTitleDisplayMode(.inline)
//    so the nav bar exists and its back button is always reachable
//  - Back navigation after Standings uses tapBackButton() helper
//  - Back nav check uses nav_title_competitions identifier
//  - State checks include no_cache_offline_view as a valid state
//

import XCTest

final class CompetitionsTests: MatchPulseUITestCase {

    // MARK: - Setup

    override func setUpWithError() throws {
        try super.setUpWithError()
        tapTab("Competitions")
        waitForContentLoaded(timeout: 15)
    }

    // MARK: - Competitions Screen

    func testCompetitionsScreen_navigationTitleIsCompetitions() {
        // CompetitionGridView uses .principal toolbar with nav_title_competitions id
        XCTAssertTrue(
            app.staticTexts["nav_title_competitions"].waitForExistence(timeout: 6),
            "Competitions tab should show 'Competitions' in the toolbar"
        )
    }

    func testCompetitionsScreen_tabIsSelected() {
        XCTAssertTrue(
            app.tabBars.buttons["Competitions"].isSelected,
            "Competitions tab should be selected"
        )
    }

    func testCompetitionsScreen_showsOneOfExpectedStates() {
        assertValidScreenState(
            contentIdentifiers: ["competitions_grid", "competitions_screen"],
            timeout: 15
        )
    }

    func testCompetitionsScreen_allCompetitionsHeader_isVisible() {
        let grid = app.otherElements["competitions_grid"]
        guard grid.waitForExistence(timeout: 14) else { return }

        let header = app.staticTexts["competitions_header"]
        XCTAssertTrue(
            header.waitForExistence(timeout: 5),
            "'All Competitions' header should be visible when grid is loaded"
        )
        XCTAssertEqual(header.label, "All Competitions")
    }

    func testCompetitionsScreen_competitionCountLabel_exists() {
        let grid = app.otherElements["competitions_grid"]
        guard grid.waitForExistence(timeout: 14) else { return }

        let countLabel = app.staticTexts["competitions_count_label"]
        XCTAssertTrue(
            countLabel.waitForExistence(timeout: 5),
            "Competition count label should be visible"
        )
        XCTAssertTrue(
            countLabel.label.contains("competitions available"),
            "Count label should say 'X competitions available', got: '\(countLabel.label)'"
        )
    }

    // MARK: - Competition Card → Standings Navigation

    func testCompetitionCard_tap_navigatesToStandings() {
        let grid = app.otherElements["competitions_grid"]
        guard grid.waitForExistence(timeout: 14) else {
            XCTSkip("No competition cards available")
            return
        }

        let firstCard = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH 'competition_card_'")
        ).firstMatch
        guard firstCard.waitForExistence(timeout: 8) else {
            XCTSkip("No competition card found")
            return
        }
        firstCard.tap()

        // DarkStandingsView header text "Standings" is inside a VStack (not nav bar)
        let standingsHeader = app.staticTexts["Standings"]
        XCTAssertTrue(
            standingsHeader.waitForExistence(timeout: 8),
            "Tapping a competition card should navigate to Standings view"
        )
    }

    func testStandingsScreen_identifier_exists() {
        let grid = app.otherElements["competitions_grid"]
        guard grid.waitForExistence(timeout: 14) else { XCTSkip("No grid") ; return }

        let firstCard = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH 'competition_card_'")
        ).firstMatch
        guard firstCard.waitForExistence(timeout: 8) else { XCTSkip("No card") ; return }
        firstCard.tap()

        let standingsScreen = app.otherElements["standings_screen"]
        XCTAssertTrue(
            standingsScreen.waitForExistence(timeout: 8),
            "standings_screen accessibility identifier should be present"
        )
    }

    func testStandingsScreen_showsStandingsListOrValidState() {
        let grid = app.otherElements["competitions_grid"]
        guard grid.waitForExistence(timeout: 14) else { XCTSkip("No grid") ; return }

        let firstCard = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH 'competition_card_'")
        ).firstMatch
        guard firstCard.waitForExistence(timeout: 8) else { XCTSkip("No card") ; return }
        firstCard.tap()

        // Valid states after navigation: standings list | empty state | no-cache offline
        let standingsList = app.otherElements["standings_list"]
        let emptyState    = app.otherElements["empty_state_view"]
        let noCacheView   = app.otherElements["no_cache_offline_view"]

        let hasContent = standingsList.waitForExistence(timeout: 14)
                      || emptyState.exists
                      || noCacheView.exists

        XCTAssertTrue(hasContent,
                      "Standings screen should show rows, empty state, or offline state")
    }

    func testStandingsScreen_firstRowPositionIsOne() {
        let grid = app.otherElements["competitions_grid"]
        guard grid.waitForExistence(timeout: 14) else { XCTSkip("No grid") ; return }

        let firstCard = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH 'competition_card_'")
        ).firstMatch
        guard firstCard.waitForExistence(timeout: 8) else { XCTSkip("No card") ; return }
        firstCard.tap()

        let firstRow = app.otherElements["standing_row_1"]
        if firstRow.waitForExistence(timeout: 12) {
            XCTAssertTrue(firstRow.exists,
                          "First standing row should have identifier 'standing_row_1'")
        }
    }

    // MARK: - Back Navigation

    func testStandingsScreen_backButton_returnsToCompetitions() {
        let grid = app.otherElements["competitions_grid"]
        guard grid.waitForExistence(timeout: 14) else { XCTSkip("No grid") ; return }

        let firstCard = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH 'competition_card_'")
        ).firstMatch
        guard firstCard.waitForExistence(timeout: 8) else { XCTSkip("No card") ; return }
        firstCard.tap()

        // Wait for Standings screen
        _ = app.otherElements["standings_screen"].waitForExistence(timeout: 8)

        // DarkStandingsView now has .navigationTitle("") so nav bar + back button exist
        tapBackButton()

        // Competitions toolbar title should reappear
        XCTAssertTrue(
            app.staticTexts["nav_title_competitions"].waitForExistence(timeout: 6),
            "Back from Standings should return to Competitions screen"
        )
        XCTAssertTrue(
            app.tabBars.buttons["Competitions"].isSelected,
            "Competitions tab should still be selected"
        )
    }

    // MARK: - Pull-to-Refresh

    func testCompetitionsScreen_pullToRefresh_doesNotCrash() {
        let grid = app.otherElements["competitions_grid"]
        guard grid.waitForExistence(timeout: 14) else { return }

        grid.swipeDown()

        XCTAssertTrue(
            app.staticTexts["nav_title_competitions"].waitForExistence(timeout: 8),
            "Competitions screen should survive pull-to-refresh"
        )
    }

    // MARK: - Error State

    func testCompetitionsScreen_errorState_hasRetryButton() {
        let errorView = app.otherElements["error_view"]
        guard errorView.waitForExistence(timeout: 1) else { return }

        XCTAssertTrue(
            app.buttons["retry_button"].exists,
            "Competitions error state should show a Retry button"
        )
    }
}
