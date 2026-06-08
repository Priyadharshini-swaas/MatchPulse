//
//  CompetitionViewModelTests.swift
//  MatchPulseTests
//
//  Tests for CompetitionViewModel covering:
//  - Online success populates competitions + writes to cache
//  - API failure with cache fallback
//  - API failure with no cache
//  - Offline with cache
//  - Offline with no cache
//  - isLoading state
//

import XCTest
@testable import MatchPulse

@MainActor
final class CompetitionViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeVM(
        result:    Result<[Competition], Error> = .success([]),
        network:   Bool                         = true,
        seedCache: [Competition]?               = nil
    ) -> (CompetitionViewModel, MockCompetitionAPI, MockLocalCache) {

        let api   = MockCompetitionAPI()
        api.result = result

        let cache = MockLocalCache()
        if let seed = seedCache { cache.seed(seed, key: .competitions) }

        let net   = MockNetworkMonitor()
        net.isConnected = network

        return (CompetitionViewModel(apiService: api, cache: cache, network: net), api, cache)
    }

    // MARK: - Online Success

    func testFetchCompetitions_success_populatesCompetitions() async {
        let comps = [
            TestFixtures.competition(id: "comp-001", name: "MLS"),
            TestFixtures.competition(id: "comp-002", name: "USL"),
            TestFixtures.competition(id: "comp-003", name: "Leagues Cup")
        ]
        let (vm, _, cache) = makeVM(result: .success(comps))

        await vm.fetchCompetitions()

        XCTAssertEqual(vm.competitions.count, 3)
        XCTAssertEqual(vm.competitions.first?.competitionName, "MLS")
        XCTAssertFalse(vm.isOffline)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(vm.lastUpdated, "Just now")

        // Cache should be populated
        let cached = cache.load([Competition].self, key: .competitions)
        XCTAssertEqual(cached?.count, 3)
    }

    func testFetchCompetitions_emptyResponse_noError() async {
        let (vm, _, _) = makeVM(result: .success([]))

        await vm.fetchCompetitions()

        XCTAssertTrue(vm.competitions.isEmpty)
        XCTAssertFalse(vm.isOffline)
        XCTAssertNil(vm.errorMessage)
    }

    func testFetchCompetitions_isLoadingFalseAfterSuccess() async {
        let (vm, _, _) = makeVM(result: .success([TestFixtures.competition()]))
        await vm.fetchCompetitions()
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - API Failure + Cache Fallback

    func testFetchCompetitions_apiFails_withCache_usesCache() async {
        let seed = [
            TestFixtures.competition(id: "comp-cached", name: "Cached League")
        ]
        let (vm, _, _) = makeVM(
            result:    .failure(TestFixtures.serverError),
            seedCache: seed
        )

        await vm.fetchCompetitions()

        XCTAssertEqual(vm.competitions.count, 1)
        XCTAssertEqual(vm.competitions.first?.competitionName, "Cached League")
        XCTAssertTrue(vm.isOffline)
        XCTAssertNil(vm.errorMessage)
    }

    func testFetchCompetitions_apiFails_noCache_setsError() async {
        let (vm, _, _) = makeVM(result: .failure(TestFixtures.serverError))

        await vm.fetchCompetitions()

        XCTAssertTrue(vm.competitions.isEmpty)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.isOffline)
    }

    func testFetchCompetitions_isLoadingFalseAfterFailure() async {
        let (vm, _, _) = makeVM(result: .failure(TestFixtures.networkError))
        await vm.fetchCompetitions()
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - Offline

    func testFetchCompetitions_offline_withCache_loadsCache() async {
        let seed = [TestFixtures.competition(id: "comp-offline", name: "Offline League")]
        let (vm, _, _) = makeVM(network: false, seedCache: seed)

        await vm.fetchCompetitions()

        XCTAssertEqual(vm.competitions.first?.competitionName, "Offline League")
        XCTAssertTrue(vm.isOffline)
    }

    func testFetchCompetitions_offline_noCache_emptyList() async {
        let (vm, _, _) = makeVM(network: false)

        await vm.fetchCompetitions()

        XCTAssertTrue(vm.competitions.isEmpty)
        XCTAssertTrue(vm.isOffline)
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - Competition Model

    func testCompetition_idComputedFromCompetitionId() {
        let comp = TestFixtures.competition(id: "mls-2026", name: "MLS")
        XCTAssertEqual(comp.id, "mls-2026")
    }

    func testFetchCompetitions_cacheOverwrittenOnNewLoad() async {
        let api   = MockCompetitionAPI()
        let cache = MockLocalCache()
        let net   = MockNetworkMonitor()
        let vm    = CompetitionViewModel(apiService: api, cache: cache, network: net)

        api.result = .success([TestFixtures.competition(id: "c1", name: "First")])
        await vm.fetchCompetitions()
        XCTAssertEqual(vm.competitions.first?.competitionName, "First")

        api.result = .success([TestFixtures.competition(id: "c2", name: "Second")])
        await vm.fetchCompetitions()
        XCTAssertEqual(vm.competitions.first?.competitionName, "Second")
    }
}
