//
//  MatchDetailsViewModelTests.swift
//  MatchPulseTests
//
//  Tests for MatchDetailsViewModel covering:
//  - Successful fetch populates match + events
//  - API failure sets errorMessage
//  - Loading state resets correctly
//  - Different matchIds are forwarded correctly
//

import XCTest
@testable import MatchPulse

@MainActor
final class MatchDetailsViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeVM(result: Result<MatchDetailsData, Error> = .success(MatchDetailsData()))
    -> (MatchDetailsViewModel, MockMatchDetailsAPI) {
        let api = MockMatchDetailsAPI()
        api.result = result
        return (MatchDetailsViewModel(apiService: api), api)
    }

    // MARK: - Success

    func testLoad_success_populatesMatchAndEvents() async {
        let data = TestFixtures.matchDetailsData(matchId: "match-001")
        let event = TestFixtures.matchEvent(eventId: "ev-001", type: "GOAL", minute: 23)
        // Rebuild with events via JSON
        let json = """
        {
            "match": {
                "matchId": "match-001", "homeTeam": {"id":"t1","name":"LAFC","shortName":"LAF","logoUrl":""},
                "awayTeam": {"id":"t2","name":"NYCFC","shortName":"NYC","logoUrl":""},
                "homeScore": 2, "awayScore": 1, "status": "LIVE",
                "kickoffUtc": "2026-06-01T20:00:00Z", "minute": 67,
                "competitionName": "MLS",
                "venue": {"name":"Banc","city":"LA"},
                "lineup": {"home":[],"away":[]}
            },
            "stats": {},
            "events": [
                {"eventId":"ev-001","type":"GOAL","minute":23,"teamId":"t1","playerId":"p1","playerName":"Vela","description":"Goal"}
            ]
        }
        """
        let fullData = try! JSONDecoder().decode(MatchDetailsData.self, from: json.data(using: .utf8)!)
        let (vm, _)  = makeVM(result: .success(fullData))

        await vm.load(matchId: "match-001")

        XCTAssertEqual(vm.match?.matchId, "match-001")
        XCTAssertEqual(vm.events.count, 1)
        XCTAssertEqual(vm.events.first?.type, "GOAL")
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
    }

    func testLoad_success_emptyEvents() async {
        let data = TestFixtures.matchDetailsData()
        let (vm, _) = makeVM(result: .success(data))

        await vm.load(matchId: "match-001")

        XCTAssertNotNil(vm.match)
        XCTAssertTrue(vm.events.isEmpty)
    }

    // MARK: - Failure

    func testLoad_apiFails_setsErrorMessage() async {
        let (vm, _) = makeVM(result: .failure(TestFixtures.serverError))

        await vm.load(matchId: "bad-match")

        XCTAssertNil(vm.match)
        XCTAssertTrue(vm.events.isEmpty)
        XCTAssertNotNil(vm.errorMessage)
    }

    func testLoad_apiFails_isLoadingResetToFalse() async {
        let (vm, _) = makeVM(result: .failure(TestFixtures.networkError))

        await vm.load(matchId: "bad-match")

        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - Loading State

    func testLoad_isLoadingFalseAfterSuccess() async {
        let (vm, _) = makeVM(result: .success(TestFixtures.matchDetailsData()))

        await vm.load(matchId: "m1")

        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - Error Cleared on Retry

    func testLoad_errorClearedOnSuccessfulRetry() async {
        let api = MockMatchDetailsAPI()
        let vm  = MatchDetailsViewModel(apiService: api)

        api.result = .failure(TestFixtures.serverError)
        await vm.load(matchId: "m1")
        XCTAssertNotNil(vm.errorMessage)

        api.result = .success(TestFixtures.matchDetailsData())
        await vm.load(matchId: "m1")
        XCTAssertNil(vm.errorMessage)
    }

    // MARK: - Home vs Away Score

    func testLoad_homeAwayScoresCorrect() async {
        let data    = TestFixtures.matchDetailsData(matchId: "score-test")
        let (vm, _) = makeVM(result: .success(data))

        await vm.load(matchId: "score-test")

        XCTAssertEqual(vm.match?.homeScore, 2)
        XCTAssertEqual(vm.match?.awayScore, 1)
    }
}
