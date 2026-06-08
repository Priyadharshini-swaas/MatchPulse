//
//  MockServices.swift
//  MatchPulseTests
//
//  All mock API services used across ViewModel tests.
//  Each mock holds a configurable Result so tests can
//  simulate success, empty responses, and errors.
//

import Foundation
@testable import MatchPulse

// MARK: - Mock Match API Service

final class MockMatchAPIService: MatchAPIServiceProtocol {

    var matchesResult:       Result<[Match],      Error> = .success([])
    var matchEventsResult:   Result<[MatchEvent], Error> = .success([])

    func fetchMatches() async throws -> [Match] {
        try matchesResult.get()
    }

    func fetchMatchEvents(matchId: String) async throws -> [MatchEvent] {
        try matchEventsResult.get()
    }
}

// MARK: - Mock Match Details API

final class MockMatchDetailsAPI: MatchDetailsAPIProtocol {

    var result: Result<MatchDetailsData, Error> = .success(MatchDetailsData())

    func fetchMatchDetails(matchId: String) async throws -> MatchDetailsData {
        try result.get()
    }
}

// MARK: - Mock Team API

final class MockTeamAPI: TeamAPIProtocol {

    var teamsResult:      Result<[TeamPlayer], Error> = .success([])
    var playersResult:    Result<[Players],    Error> = .success([])
    var teamDetailResult: Result<TeamDetail,   Error> = .success(TeamDetail())

    func fetchTeams() async throws -> [TeamPlayer] {
        try teamsResult.get()
    }

    func fetchPlayers(teamId: String) async throws -> [Players] {
        try playersResult.get()
    }

    func fetchTeamDetails(teamId: String) async throws -> TeamDetail {
        try teamDetailResult.get()
    }
}

// MARK: - Mock Standings API

final class MockStandingsAPI: StandingsAPIProtocol {

    var result: Result<StandingsData, Error> = .success(StandingsData())

    func fetchStandings(competitionId: String) async throws -> StandingsData {
        try result.get()
    }
}

// MARK: - Mock Competition API

final class MockCompetitionAPI: CompetitionAPIProtocol {

    var result: Result<[Competition], Error> = .success([])

    func fetchCompetitions() async throws -> [Competition] {
        try result.get()
    }
}

// MARK: - Mock Content API

final class MockContentAPI: ContentAPIProtocol {

    var result: Result<[ContentItem], Error> = .success([])

    func fetchContent() async throws -> [ContentItem] {
        try result.get()
    }
}

// MARK: - Mock Network Monitor

final class MockNetworkMonitor: NetworkStatusProtocol {
    var isConnected: Bool = true
}

// MARK: - Mock Local Cache

final class MockLocalCache: LocalCacheProtocol {

    // Tracks save calls for assertion
    var savedValues: [String: Data] = [:]
    var lastUpdatedString: String   = "Just now"

    // Pre-seed this to simulate cached data being available
    var seedData: [String: Data] = [:]

    func save<T: Encodable>(_ value: T, key: CacheKey) {
        savedValues[key.rawValue] = try? JSONEncoder().encode(value)
    }

    func load<T: Decodable>(_ type: T.Type, key: CacheKey) -> T? {
        // Check seed first, then previously saved
        let data = seedData[key.rawValue] ?? savedValues[key.rawValue]
        guard let data else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func lastUpdatedText(for key: CacheKey) -> String {
        lastUpdatedString
    }

    // Helper to seed typed data before a test runs
    func seed<T: Encodable>(_ value: T, key: CacheKey) {
        seedData[key.rawValue] = try? JSONEncoder().encode(value)
    }
}
