//
//  ContentViewModelTests.swift
//  MatchPulseTests
//
//  Tests for ContentViewModel covering:
//  - Online success populates items + writes cache
//  - API failure fallback to cache
//  - API failure no cache → errorMessage
//  - Offline states
//  - isLoading reset
//

import XCTest
@testable import MatchPulse

@MainActor
final class ContentViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeVM(
        result:    Result<[ContentItem], Error> = .success([]),
        network:   Bool                         = true,
        seedCache: [ContentItem]?               = nil
    ) -> (ContentViewModel, MockContentAPI, MockLocalCache) {

        let api   = MockContentAPI()
        api.result = result

        let cache = MockLocalCache()
        if let seed = seedCache { cache.seed(seed, key: .content) }

        let net   = MockNetworkMonitor()
        net.isConnected = network

        return (ContentViewModel(apiService: api, cache: cache, network: net), api, cache)
    }

    // MARK: - Online Success

    func testLoadContent_success_populatesItems() async {
        let items = [
            TestFixtures.contentItem(contentId: "c1", headline: "Goal Highlights"),
            TestFixtures.contentItem(contentId: "c2", headline: "Match Preview")
        ]
        let (vm, _, cache) = makeVM(result: .success(items))

        await vm.loadContent()

        XCTAssertEqual(vm.items.count, 2)
        XCTAssertEqual(vm.items.first?.headline, "Goal Highlights")
        XCTAssertFalse(vm.isOffline)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(vm.lastUpdated, "Just now")

        // Saved to cache
        XCTAssertNotNil(cache.load([ContentItem].self, key: .content))
    }

    func testLoadContent_emptyItems_noError() async {
        let (vm, _, _) = makeVM(result: .success([]))

        await vm.loadContent()

        XCTAssertTrue(vm.items.isEmpty)
        XCTAssertNil(vm.errorMessage)
    }

    func testLoadContent_isLoadingFalseAfterSuccess() async {
        let (vm, _, _) = makeVM(result: .success([TestFixtures.contentItem()]))
        await vm.loadContent()
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - API Failure + Cache Fallback

    func testLoadContent_apiFails_withCache_usesCache() async {
        let seed = [TestFixtures.contentItem(contentId: "cached", headline: "Cached Content")]
        let (vm, _, _) = makeVM(
            result:    .failure(TestFixtures.serverError),
            seedCache: seed
        )

        await vm.loadContent()

        XCTAssertEqual(vm.items.first?.headline, "Cached Content")
        XCTAssertTrue(vm.isOffline)
        XCTAssertNil(vm.errorMessage)
    }

    func testLoadContent_apiFails_noCache_setsError() async {
        let (vm, _, _) = makeVM(result: .failure(TestFixtures.networkError))

        await vm.loadContent()

        XCTAssertTrue(vm.items.isEmpty)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.isOffline)
    }

    func testLoadContent_isLoadingFalseAfterFailure() async {
        let (vm, _, _) = makeVM(result: .failure(TestFixtures.serverError))
        await vm.loadContent()
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - Offline

    func testLoadContent_offline_withCache() async {
        let seed = [TestFixtures.contentItem(contentId: "off1", headline: "Offline Item")]
        let (vm, _, _) = makeVM(network: false, seedCache: seed)

        await vm.loadContent()

        XCTAssertEqual(vm.items.first?.headline, "Offline Item")
        XCTAssertTrue(vm.isOffline)
    }

    func testLoadContent_offline_noCache_emptyItems() async {
        let (vm, _, _) = makeVM(network: false)

        await vm.loadContent()

        XCTAssertTrue(vm.items.isEmpty)
        XCTAssertTrue(vm.isOffline)
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - Error Reset on Retry

    func testLoadContent_errorClearedOnRetry() async {
        let api   = MockContentAPI()
        let cache = MockLocalCache()
        let net   = MockNetworkMonitor()
        let vm    = ContentViewModel(apiService: api, cache: cache, network: net)

        api.result = .failure(TestFixtures.serverError)
        await vm.loadContent()
        XCTAssertNotNil(vm.errorMessage)

        api.result = .success([TestFixtures.contentItem()])
        await vm.loadContent()
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.items.isEmpty)
    }

    // MARK: - Content Item Properties

    func testContentItem_idIsContentId() {
        let item = TestFixtures.contentItem(contentId: "unique-id-42")
        XCTAssertEqual(item.id, "unique-id-42")
    }

    func testContentItem_tagsDecoded() {
        let item = TestFixtures.contentItem()
        XCTAssertTrue(item.tags.contains("MLS"))
        XCTAssertTrue(item.tags.contains("LAFC"))
    }
}
