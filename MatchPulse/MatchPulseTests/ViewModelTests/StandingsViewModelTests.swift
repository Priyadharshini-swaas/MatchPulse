//
//  StandingsViewModelTests.swift
//  MatchPulseTests
//
//  Tests for StandingsViewModel covering:
//  - Online success populates standings, competitionName, season
//  - competitionId "#"-prefix stripping
//  - API failure + cache fallback
//  - Offline mode
//  - isLoading transitions
//

import XCTest
@testable import MatchPulse

@MainActor
final class StandingsViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeVM(
        result:    Result<StandingsData, Error> = .success(StandingsData()),
        network:   Bool                         = true,
        seedCache: StandingsData?               = nil
    ) -> (StandingsViewModel, MockStandingsAPI, MockLocalCache) {

        let api = MockStandingsAPI()
        api.result = result

        let cache = MockLocalCache()
        if let seed = seedCache { cache.seed(seed, key: .standings) }

        let net = MockNetworkMonitor()
        net.isConnected = network

        return (StandingsViewModel(apiService: api, cache: cache, network: net), api, cache)
    }

    // MARK: - Online Success

    func testFetchStandings_success_populatesStandings() async {
        let data   = TestFixtures.standingsData(count: 5)
        let (vm, _, cache) = makeVM(result: .success(data))

        await vm.fetchStandings(competitionId: "comp-001")

        XCTAssertEqual(vm.standings.count, 5)
        XCTAssertEqual(vm.competitionName, "MLS")
        XCTAssertEqual(vm.season, "2026")
        XCTAssertFalse(vm.isOffline)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(vm.lastUpdated, "Just now")

        // Should be written to cache
        let cached = cache.load(StandingsData.self, key: .standings)
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.standings.count, 5)
    }

    func testFetchStandings_success_isLoadingFalse() async {
        let (vm, _, _) = makeVM(result: .success(TestFixtures.standingsData()))
        await vm.fetchStandings(competitionId: "comp-001")
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - competitionId Stripping

    func testFetchStandings_stripsHashPrefix() async {
        // When competitionId contains "#", only the part after it should be sent
        let api   = MockStandingsAPI()
        var receivedId: String = ""

        // Wrap to capture
        class CapturingMock: StandingsAPIProtocol {
            var inner: MockStandingsAPI
            var capturedId: String = ""
            init(_ inner: MockStandingsAPI) { self.inner = inner }
            func fetchStandings(competitionId: String) async throws -> StandingsData {
                capturedId = competitionId
                return try await inner.fetchStandings(competitionId: competitionId)
            }
        }

        let mock = CapturingMock(api)
        api.result = .success(TestFixtures.standingsData())
        let vm = StandingsViewModel(
            apiService: mock,
            cache:      MockLocalCache(),
            network:    MockNetworkMonitor()
        )

        await vm.fetchStandings(competitionId: "COMP#pl-premier-league")

        XCTAssertEqual(mock.capturedId, "pl-premier-league")
    }

    // MARK: - API Failure + Cache Fallback

    func testFetchStandings_apiFails_withCache_fallsBack() async {
        let seed = TestFixtures.standingsData(count: 3)
        let (vm, _, _) = makeVM(
            result:    .failure(TestFixtures.serverError),
            seedCache: seed
        )

        await vm.fetchStandings(competitionId: "comp-001")

        XCTAssertEqual(vm.standings.count, 3)
        XCTAssertTrue(vm.isOffline)
        XCTAssertNil(vm.errorMessage) // Cache available → no error shown
    }

    func testFetchStandings_apiFails_noCache_setsError() async {
        let (vm, _, _) = makeVM(result: .failure(TestFixtures.serverError))

        await vm.fetchStandings(competitionId: "comp-001")

        XCTAssertTrue(vm.standings.isEmpty)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.isOffline)
    }

    // MARK: - Offline

    func testFetchStandings_offline_withCache() async {
        let seed = TestFixtures.standingsData(count: 4)
        let (vm, _, _) = makeVM(network: false, seedCache: seed)

        await vm.fetchStandings(competitionId: "comp-001")

        XCTAssertEqual(vm.standings.count, 4)
        XCTAssertTrue(vm.isOffline)
    }

    func testFetchStandings_offline_noCache_emptyStandings() async {
        let (vm, _, _) = makeVM(network: false)

        await vm.fetchStandings(competitionId: "comp-001")

        XCTAssertTrue(vm.standings.isEmpty)
        XCTAssertTrue(vm.isOffline)
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - Standings Ordering (integration hint)

    func testFetchStandings_standingsReturnedInAPIOrder() async {
        let data = TestFixtures.standingsData(count: 3)
        let (vm, _, _) = makeVM(result: .success(data))

        await vm.fetchStandings(competitionId: "comp-001")

        // Position 1 should come first as API returns them
        XCTAssertEqual(vm.standings.first?.position, 1)
        XCTAssertEqual(vm.standings.last?.position, 3)
    }
}
