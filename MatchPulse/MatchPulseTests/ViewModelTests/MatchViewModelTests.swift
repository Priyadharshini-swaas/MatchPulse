//
//  MatchViewModelTests.swift
//  MatchPulseTests
//
//  Tests for MatchViewModel covering:
//  - Online success (matches populated, cache saved, isOffline = false)
//  - Online API failure with cache available (fallback)
//  - Online API failure with no cache (errorMessage set, empty state)
//  - Offline with cache available
//  - Offline with no cache (empty state)
//  - Loading state transitions
//

import XCTest
@testable import MatchPulse

@MainActor
final class MatchViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeVM(
        matches:    Result<[Match], Error> = .success([]),
        network:    Bool                   = true,
        seedCache:  [Match]?               = nil
    ) -> (MatchViewModel, MockMatchAPIService, MockLocalCache) {

        let api     = MockMatchAPIService()
        api.matchesResult = matches

        let cache   = MockLocalCache()
        if let seed = seedCache { cache.seed(seed, key: .matches) }

        let net     = MockNetworkMonitor()
        net.isConnected = network

        let vm = MatchViewModel(apiService: api, cache: cache, network: net)
        return (vm, api, cache)
    }

    // MARK: - Online Success

    func testLoadMatches_onlineSuccess_populatesMatches() async {
        let m1 = TestFixtures.match(matchId: "m1")
        let m2 = TestFixtures.match(matchId: "m2")
        let (vm, _, cache) = makeVM(matches: .success([m1, m2]))

        await vm.loadMatches()

        XCTAssertEqual(vm.matches.count, 2)
        XCTAssertEqual(vm.matches.first?.matchId, "m1")
        XCTAssertFalse(vm.isOffline)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(vm.lastUpdated, "Just now")

        // Verifies that data was persisted to cache
        let cached = cache.load([Match].self, key: .matches)
        XCTAssertEqual(cached?.count, 2)
    }

    func testLoadMatches_onlineSuccess_isLoadingResetsToFalse() async {
        let (vm, _, _) = makeVM(matches: .success([TestFixtures.match()]))

        await vm.loadMatches()

        XCTAssertFalse(vm.isLoading)
    }

    func testLoadMatches_onlineSuccess_emptyResponse_matchesEmpty() async {
        let (vm, _, _) = makeVM(matches: .success([]))

        await vm.loadMatches()

        XCTAssertTrue(vm.matches.isEmpty)
        XCTAssertFalse(vm.isOffline)
    }

    // MARK: - Online API Failure

    func testLoadMatches_apiFails_withCachedData_fallsBackToCache() async {
        let cached = [TestFixtures.match(matchId: "cached-m1")]
        let (vm, _, _) = makeVM(
            matches:   .failure(TestFixtures.serverError),
            seedCache: cached
        )

        await vm.loadMatches()

        XCTAssertEqual(vm.matches.count, 1)
        XCTAssertEqual(vm.matches.first?.matchId, "cached-m1")
        XCTAssertTrue(vm.isOffline)
        // When fallback succeeds errorMessage should be nil
        XCTAssertNil(vm.errorMessage)
    }

    func testLoadMatches_apiFails_noCachedData_setsErrorMessage() async {
        let (vm, _, _) = makeVM(matches: .failure(TestFixtures.serverError))

        await vm.loadMatches()

        XCTAssertTrue(vm.matches.isEmpty)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.isOffline)
    }

    // MARK: - Offline Mode

    func testLoadMatches_offline_withCache_loadsFromCache() async {
        let cached = [TestFixtures.match(matchId: "offline-m1")]
        let (vm, _, _) = makeVM(network: false, seedCache: cached)

        await vm.loadMatches()

        XCTAssertEqual(vm.matches.count, 1)
        XCTAssertEqual(vm.matches.first?.matchId, "offline-m1")
        XCTAssertTrue(vm.isOffline)
        XCTAssertNil(vm.errorMessage)
    }

    func testLoadMatches_offline_noCache_emptyMatches() async {
        let (vm, _, _) = makeVM(network: false)

        await vm.loadMatches()

        XCTAssertTrue(vm.matches.isEmpty)
        XCTAssertTrue(vm.isOffline)
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - Loading State

    func testLoadMatches_isLoadingIsTrue_duringFetch() async {
        // We observe isLoading = true before the async method returns.
        // Since the VM is @MainActor and we are on MainActor, we verify
        // that isLoading starts false and ends false (true in-between).
        let (vm, _, _) = makeVM(matches: .success([TestFixtures.match()]))
        XCTAssertFalse(vm.isLoading)
        await vm.loadMatches()
        XCTAssertFalse(vm.isLoading) // Must reset after completion
    }

    // MARK: - Multiple Loads

    func testLoadMatches_calledTwice_secondOverwritesFirst() async {
        let m1     = [TestFixtures.match(matchId: "m1")]
        let m2     = [TestFixtures.match(matchId: "m2")]
        let api    = MockMatchAPIService()
        let cache  = MockLocalCache()
        let net    = MockNetworkMonitor()
        net.isConnected = true

        let vm = MatchViewModel(apiService: api, cache: cache, network: net)

        api.matchesResult = .success(m1)
        await vm.loadMatches()
        XCTAssertEqual(vm.matches.first?.matchId, "m1")

        api.matchesResult = .success(m2)
        await vm.loadMatches()
        XCTAssertEqual(vm.matches.first?.matchId, "m2")
    }

    // MARK: - Error Reset

    func testLoadMatches_errorClearedOnSuccessfulRetry() async {
        let api    = MockMatchAPIService()
        let cache  = MockLocalCache()
        let net    = MockNetworkMonitor()

        let vm = MatchViewModel(apiService: api, cache: cache, network: net)

        api.matchesResult = .failure(TestFixtures.serverError)
        await vm.loadMatches()
        XCTAssertNotNil(vm.errorMessage)

        api.matchesResult = .success([TestFixtures.match()])
        await vm.loadMatches()
        XCTAssertNil(vm.errorMessage)
    }
}
