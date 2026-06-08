//
//  LocalCacheTests.swift
//  MatchPulseTests
//
//  Tests for LocalCache using an isolated UserDefaults suite so
//  no test data bleeds into the real app's cache or other tests.
//
//  Covers:
//  - save + load round-trip for every CacheKey type
//  - Load returns nil when nothing is saved
//  - clear removes a single key
//  - clearAll removes every key
//  - isCacheStale with fresh data
//  - cacheAge returns approximately correct age
//  - lastUpdatedText returns a non-empty string after save
//

import XCTest
@testable import MatchPulse

final class LocalCacheTests: XCTestCase {

    // Each test gets its own isolated suite — no cross-test contamination.
    private var cache: LocalCache!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "MatchPulseTests_\(UUID().uuidString)"
        cache     = LocalCache(defaults: UserDefaults(suiteName: suiteName)!)
    }

    override func tearDown() {
        // Wipe the test suite so macOS doesn't accumulate test defaults
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
        cache = nil
        super.tearDown()
    }

    // MARK: - Matches

    func testSaveAndLoad_matches_roundTrip() {
        let matches = [
            TestFixtures.match(matchId: "m1"),
            TestFixtures.match(matchId: "m2")
        ]
        cache.save(matches, key: .matches)

        let loaded = cache.load([Match].self, key: .matches)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.count, 2)
        XCTAssertEqual(loaded?.first?.matchId, "m1")
        XCTAssertEqual(loaded?.last?.matchId,  "m2")
    }

    func testLoad_matches_beforeSave_returnsNil() {
        let loaded = cache.load([Match].self, key: .matches)
        XCTAssertNil(loaded)
    }

    // MARK: - Competitions

    func testSaveAndLoad_competitions_roundTrip() {
        let comps = [
            TestFixtures.competition(id: "c1", name: "MLS"),
            TestFixtures.competition(id: "c2", name: "USL")
        ]
        cache.save(comps, key: .competitions)

        let loaded = cache.load([Competition].self, key: .competitions)
        XCTAssertEqual(loaded?.count, 2)
        XCTAssertEqual(loaded?[1].competitionName, "USL")
    }

    // MARK: - Teams

    func testSaveAndLoad_teams_roundTrip() {
        let teams = [
            TestFixtures.teamPlayer(id: "team#t1", name: "LA FC"),
            TestFixtures.teamPlayer(id: "team#t2", name: "NYCFC")
        ]
        cache.save(teams, key: .teams)

        let loaded = cache.load([TeamPlayer].self, key: .teams)
        XCTAssertEqual(loaded?.count, 2)
        XCTAssertEqual(loaded?.first?.name, "LA FC")
    }

    // MARK: - Standings

    func testSaveAndLoad_standings_roundTrip() {
        let data = TestFixtures.standingsData(count: 5)
        cache.save(data, key: .standings)

        let loaded = cache.load(StandingsData.self, key: .standings)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.standings.count, 5)
        XCTAssertEqual(loaded?.competitionName, "MLS")
    }

    // MARK: - Content

    func testSaveAndLoad_content_roundTrip() {
        let items = [
            TestFixtures.contentItem(contentId: "c1"),
            TestFixtures.contentItem(contentId: "c2")
        ]
        cache.save(items, key: .content)

        let loaded = cache.load([ContentItem].self, key: .content)
        XCTAssertEqual(loaded?.count, 2)
    }

    // MARK: - Clear Single Key

    func testClear_removesOnlyTargetKey() {
        cache.save([TestFixtures.match()], key: .matches)
        cache.save([TestFixtures.competition()], key: .competitions)

        cache.clear(key: .matches)

        XCTAssertNil(cache.load([Match].self,       key: .matches))
        XCTAssertNotNil(cache.load([Competition].self, key: .competitions))
    }

    // MARK: - ClearAll

    func testClearAll_removesEveryKey() {
        cache.save([TestFixtures.match()],       key: .matches)
        cache.save([TestFixtures.competition()], key: .competitions)
        cache.save([TestFixtures.teamPlayer()],  key: .teams)

        cache.clearAll()

        XCTAssertNil(cache.load([Match].self,       key: .matches))
        XCTAssertNil(cache.load([Competition].self, key: .competitions))
        XCTAssertNil(cache.load([TeamPlayer].self,  key: .teams))
    }

    // MARK: - Cache Age

    func testCacheAge_afterSave_isVerySmall() {
        cache.save([TestFixtures.match()], key: .matches)
        let age = cache.cacheAge(for: .matches)
        XCTAssertNotNil(age)
        XCTAssertLessThan(age!, 2.0) // Under 2 seconds since we just saved
    }

    func testCacheAge_beforeSave_returnsNil() {
        XCTAssertNil(cache.cacheAge(for: .matches))
    }

    // MARK: - isCacheStale

    func testIsCacheStale_freshData_notStale() {
        cache.save([TestFixtures.match()], key: .matches)
        // maxAge = 300s; data is ~0s old
        XCTAssertFalse(cache.isCacheStale(key: .matches, maxAge: 300))
    }

    func testIsCacheStale_noData_returnsTrue() {
        XCTAssertTrue(cache.isCacheStale(key: .matches))
    }

    func testIsCacheStale_tinyMaxAge_returnsStale() {
        // Save then immediately check with maxAge = 0 → stale
        cache.save([TestFixtures.match()], key: .matches)
        XCTAssertTrue(cache.isCacheStale(key: .matches, maxAge: 0))
    }

    // MARK: - lastUpdatedText

    func testLastUpdatedText_afterSave_returnsNonEmpty() {
        cache.save([TestFixtures.match()], key: .matches)
        let text = cache.lastUpdatedText(for: .matches)
        XCTAssertFalse(text.isEmpty)
        XCTAssertNotEqual(text, "Never")
    }

    func testLastUpdatedText_beforeSave_returnsNever() {
        let text = cache.lastUpdatedText(for: .matches)
        XCTAssertEqual(text, "Never")
    }

    // MARK: - Overwrite

    func testSave_overwrite_returnsNewValue() {
        cache.save([TestFixtures.match(matchId: "old")], key: .matches)
        cache.save([TestFixtures.match(matchId: "new")], key: .matches)

        let loaded = cache.load([Match].self, key: .matches)
        XCTAssertEqual(loaded?.first?.matchId, "new")
    }

    // MARK: - CacheKey Helpers

    func testCacheKey_timestampKey_hasSuffix() {
        XCTAssertEqual(CacheKey.matches.timestampKey,      "cache_matches_timestamp")
        XCTAssertEqual(CacheKey.competitions.timestampKey, "cache_competitions_timestamp")
        XCTAssertEqual(CacheKey.teams.timestampKey,        "cache_teams_timestamp")
        XCTAssertEqual(CacheKey.standings.timestampKey,    "cache_standings_timestamp")
        XCTAssertEqual(CacheKey.content.timestampKey,      "cache_content_timestamp")
    }

    func testCacheKey_rawValues() {
        XCTAssertEqual(CacheKey.matches.rawValue,      "cache_matches")
        XCTAssertEqual(CacheKey.competitions.rawValue, "cache_competitions")
        XCTAssertEqual(CacheKey.teams.rawValue,        "cache_teams")
        XCTAssertEqual(CacheKey.standings.rawValue,    "cache_standings")
        XCTAssertEqual(CacheKey.content.rawValue,      "cache_content")
    }
}
