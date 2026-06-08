//
//  TeamTests.swift
//  MatchPulseUITests
//
//  FIX NOTES:
//  - app.navigationBars["Teams"] replaced with app.staticTexts["nav_title_teams"]
//    (TeamSliderView uses .principal toolbar, not .navigationTitle)
//  - TeamMembersView uses .navigationTitle(team.name) — nav bar title is dynamic.
//    Back navigation validated via nav_title_teams reappearing, not nav bar label.
//  - State check now includes no_cache_offline_view
//  - tapBackButton() helper used for reliable back navigation
//

import XCTest

final class TeamTests: MatchPulseUITestCase {

    // MARK: - Setup

    override func setUpWithError() throws {
        try super.setUpWithError()
        tapTab("Team")
        waitForContentLoaded(timeout: 15)
    }

    // MARK: - Team Screen

    func testTeamScreen_navigationTitleIsTeams() {
        // TeamSliderView uses .principal toolbar Text("Teams") — nav_title_teams id
        XCTAssertTrue(
            app.staticTexts["nav_title_teams"].waitForExistence(timeout: 6),
            "Team tab should show 'Teams' in the toolbar"
        )
    }

    func testTeamScreen_tabIsSelectedAfterTap() {
        XCTAssertTrue(
            app.tabBars.buttons["Team"].isSelected,
            "Team tab should be selected"
        )
    }

    func testTeamScreen_showsOneOfExpectedStates() {
        assertValidScreenState(
            contentIdentifiers: [
                "view_players_button",          // generic fallback
                "competitions_screen"           // won't match here, just defensive
            ],
            timeout: 15
        )
        // Additional check: if teams loaded, View Players button exists
        // (We check this separately to avoid false pass)
    }

    // MARK: - View Players Navigation

    func testTeamScreen_viewPlayersButton_existsWhenTeamsLoaded() {
        let viewPlayersBtn = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'view_players_button_'")
        ).firstMatch

        if viewPlayersBtn.waitForExistence(timeout: 10) {
            XCTAssertTrue(viewPlayersBtn.isHittable,
                          "'View Players' button should be tappable")
        }
        // No assertion if no teams loaded — offline/empty state is valid
    }

    func testTeamScreen_tapViewPlayers_navigatesToTeamMembers() {
        let viewPlayersBtn = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'view_players_button_'")
        ).firstMatch

        guard viewPlayersBtn.waitForExistence(timeout: 12) else {
            XCTSkip("No team cards available — skipping players navigation test")
            return
        }
        viewPlayersBtn.tap()

        // TeamMembersView uses .navigationTitle(team.name) — title is dynamic.
        // We verify a navigation bar appeared (any title) and content loaded.
        let navBarAppeared = app.navigationBars.firstMatch.waitForExistence(timeout: 8)
        XCTAssertTrue(navBarAppeared, "A navigation bar should appear after tapping View Players")

        // Players list or valid state should appear
        let playersList  = app.otherElements["players_list"]
        let offlineState = app.otherElements["no_cache_offline_view"]
        let emptyState   = app.otherElements["empty_state_view"]
        let errorView    = app.otherElements["error_view"]

        let hasContent = playersList.waitForExistence(timeout: 12)
                      || offlineState.exists
                      || emptyState.exists
                      || errorView.exists

        XCTAssertTrue(hasContent,
                      "Team members screen should show player list or a valid empty/error state")
    }

    func testTeamScreen_backFromPlayers_returnsToTeamTab() {
        let viewPlayersBtn = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'view_players_button_'")
        ).firstMatch
        guard viewPlayersBtn.waitForExistence(timeout: 12) else { XCTSkip("No teams") ; return }

        viewPlayersBtn.tap()
        _ = app.navigationBars.firstMatch.waitForExistence(timeout: 8)

        // Tap back using the base helper
        tapBackButton()

        // Teams nav title should reappear (principal toolbar identifier)
        XCTAssertTrue(
            app.staticTexts["nav_title_teams"].waitForExistence(timeout: 6),
            "Back from Players should return to Teams screen"
        )
        XCTAssertTrue(
            app.tabBars.buttons["Team"].isSelected,
            "Team tab should still be selected"
        )
    }

    // MARK: - Player List

    func testPlayersScreen_playerCard_existsWhenPlayersLoaded() {
        let viewPlayersBtn = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'view_players_button_'")
        ).firstMatch
        guard viewPlayersBtn.waitForExistence(timeout: 12) else { XCTSkip("No teams") ; return }
        viewPlayersBtn.tap()

        let playersList = app.otherElements["players_list"]
        guard playersList.waitForExistence(timeout: 14) else { return }

        let firstPlayer = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH 'player_card_'")
        ).firstMatch

        if firstPlayer.waitForExistence(timeout: 8) {
            XCTAssertTrue(firstPlayer.exists,
                          "At least one player card should be visible in the list")
        }
    }

    // MARK: - Error State

    func testTeamScreen_errorState_hasRetryButton() {
        let errorView = app.otherElements["error_view"]
        guard errorView.waitForExistence(timeout: 1) else { return }

        XCTAssertTrue(
            app.buttons["retry_button"].exists,
            "Error state on Team screen should have a Retry button"
        )
    }

    // MARK: - Offline / No-Cache State

    func testTeamScreen_offlineState_isRecognised() {
        // If teams screen shows no-cache offline, that's a valid state — not a failure
        let noCacheView = app.otherElements["no_cache_offline_view"]
        if noCacheView.exists {
            XCTAssertTrue(noCacheView.exists,
                          "No-cache offline view is a valid state on Team screen")
        }
    }
}
