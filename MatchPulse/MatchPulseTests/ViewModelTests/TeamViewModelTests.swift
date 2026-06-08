//
//  TeamViewModelTests.swift
//  MatchPulseTests
//
//  Tests for TeamViewModel covering:
//  - loadTeams: success, failure, offline, cache fallback
//  - loadPlayers: success (parallel fetch), failure, offline
//  - Cache persistence after successful fetch
//  - isOffline flag accuracy
//

import XCTest
@testable import MatchPulse

@MainActor
final class TeamViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeVM(
        teamsResult:      Result<[TeamPlayer], Error> = .success([]),
        playersResult:    Result<[Players],    Error> = .success([]),
        teamDetailResult: Result<TeamDetail,   Error> = .success(TeamDetail()),
        network:          Bool                        = true,
        seedTeamsCache:   [TeamPlayer]?               = nil
    ) -> (TeamViewModel, MockTeamAPI, MockLocalCache) {

        let api = MockTeamAPI()
        api.teamsResult      = teamsResult
        api.playersResult    = playersResult
        api.teamDetailResult = teamDetailResult

        let cache = MockLocalCache()
        if let seed = seedTeamsCache { cache.seed(seed, key: .teams) }

        let net = MockNetworkMonitor()
        net.isConnected = network

        return (TeamViewModel(apiService: api, cache: cache, network: net), api, cache)
    }

    // MARK: - loadTeams — Online Success

    func testLoadTeams_success_populatesTeams() async {
        let teams = [
            TestFixtures.teamPlayer(id: "team#t1", name: "LA FC"),
            TestFixtures.teamPlayer(id: "team#t2", name: "NYCFC")
        ]
        let (vm, _, cache) = makeVM(teamsResult: .success(teams))

        await vm.loadTeams()

        XCTAssertEqual(vm.teams.count, 2)
        XCTAssertEqual(vm.teams.first?.name, "LA FC")
        XCTAssertFalse(vm.isOffline)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(vm.lastUpdated, "Just now")
        // Should persist to cache
        XCTAssertNotNil(cache.load([TeamPlayer].self, key: .teams))
    }

    func testLoadTeams_success_isLoadingFalseAfterLoad() async {
        let (vm, _, _) = makeVM(teamsResult: .success([TestFixtures.teamPlayer()]))
        await vm.loadTeams()
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - loadTeams — API Failure with Cache

    func testLoadTeams_apiFails_withCache_fallsBack() async {
        let cached = [TestFixtures.teamPlayer(id: "team#c1", name: "Cached Team")]
        let (vm, _, _) = makeVM(
            teamsResult:    .failure(TestFixtures.serverError),
            seedTeamsCache: cached
        )

        await vm.loadTeams()

        XCTAssertEqual(vm.teams.first?.name, "Cached Team")
        XCTAssertTrue(vm.isOffline)
        XCTAssertNil(vm.errorMessage) // No error when cache available
    }

    func testLoadTeams_apiFails_noCache_setsError() async {
        let (vm, _, _) = makeVM(teamsResult: .failure(TestFixtures.serverError))

        await vm.loadTeams()

        XCTAssertTrue(vm.teams.isEmpty)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.isOffline)
    }

    // MARK: - loadTeams — Offline

    func testLoadTeams_offline_withCache_loadsFromCache() async {
        let cached = [TestFixtures.teamPlayer(id: "team#offline", name: "Offline Team")]
        let (vm, _, _) = makeVM(network: false, seedTeamsCache: cached)

        await vm.loadTeams()

        XCTAssertEqual(vm.teams.first?.name, "Offline Team")
        XCTAssertTrue(vm.isOffline)
    }

    func testLoadTeams_offline_noCache_emptyTeams() async {
        let (vm, _, _) = makeVM(network: false)

        await vm.loadTeams()

        XCTAssertTrue(vm.teams.isEmpty)
        XCTAssertTrue(vm.isOffline)
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - loadPlayers — Online Success

    func testLoadPlayers_success_populatesPlayersAndTeamDetail() async {
        let players = [
            TestFixtures.player(playerId: "p1", name: "Carlos Vela"),
            TestFixtures.player(playerId: "p2", name: "Ilie Sanchez")
        ]
        let detail  = TestFixtures.teamDetail(teamId: "team#t1", name: "LA FC")
        let (vm, _, _) = makeVM(
            playersResult:    .success(players),
            teamDetailResult: .success(detail)
        )

        await vm.loadPlayers(teamId: "t1")

        XCTAssertEqual(vm.players.count, 2)
        XCTAssertEqual(vm.players.first?.name, "Carlos Vela")
        XCTAssertEqual(vm.team.name, "LA FC")
        XCTAssertFalse(vm.isOffline)
        XCTAssertNil(vm.errorMessage)
    }

    func testLoadPlayers_success_isLoadingFalse() async {
        let (vm, _, _) = makeVM(
            playersResult:    .success([TestFixtures.player()]),
            teamDetailResult: .success(TestFixtures.teamDetail())
        )
        await vm.loadPlayers(teamId: "t1")
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - loadPlayers — API Failure

    func testLoadPlayers_apiFails_setsErrorAndOffline() async {
        let (vm, _, _) = makeVM(playersResult: .failure(TestFixtures.serverError))

        await vm.loadPlayers(teamId: "t1")

        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.isOffline)
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - loadPlayers — Offline

    func testLoadPlayers_offline_emptyPlayers_noErrorMessage() async {
        let (vm, _, _) = makeVM(network: false)

        await vm.loadPlayers(teamId: "t1")

        XCTAssertTrue(vm.isOffline)
        XCTAssertNil(vm.errorMessage) // No error — just offline with no data
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - teamId Parsing

    func testTeamPlayer_teamIdStripsPrefix() {
        let team = TestFixtures.teamPlayer(id: "team#lafc-123")
        XCTAssertEqual(team.teamId, "lafc-123")
    }

    func testTeamPlayer_teamIdNoHashSign_returnsFullId() {
        let team = TestFixtures.teamPlayer(id: "lafc-123")
        XCTAssertEqual(team.teamId, "lafc-123")
    }

    // MARK: - TeamDetail cleanTeamId

    func testTeamDetail_cleanTeamId_stripsPrefix() {
        let detail = TestFixtures.teamDetail(teamId: "team#lafc-xyz")
        XCTAssertEqual(detail.cleanTeamId, "lafc-xyz")
    }
}
