//
//  ServiceProtocols.swift
//  MatchPulse
//
//  Protocols that decouple ViewModels from concrete singletons,
//  enabling full dependency-injection and unit-testability.
//

import Foundation

// MARK: - Match API
protocol MatchAPIServiceProtocol {
    func fetchMatches() async throws -> [Match]
    func fetchMatchEvents(matchId: String) async throws -> [MatchEvent]
}
extension MatchAPIService: MatchAPIServiceProtocol {}

// MARK: - Match Details API
protocol MatchDetailsAPIProtocol {
    func fetchMatchDetails(matchId: String) async throws -> MatchDetailsData
}
extension MatchDetailsAPI: MatchDetailsAPIProtocol {}

// MARK: - Team API
protocol TeamAPIProtocol {
    func fetchTeams() async throws -> [TeamPlayer]
    func fetchPlayers(teamId: String) async throws -> [Players]
    func fetchTeamDetails(teamId: String) async throws -> TeamDetail
}
extension TeamAPI: TeamAPIProtocol {}

// MARK: - Standings API
protocol StandingsAPIProtocol {
    func fetchStandings(competitionId: String) async throws -> StandingsData
}
extension StandingsAPI: StandingsAPIProtocol {}

// MARK: - Competition API
protocol CompetitionAPIProtocol {
    func fetchCompetitions() async throws -> [Competition]
}
extension CompetitionAPI: CompetitionAPIProtocol {}

// MARK: - Content API
protocol ContentAPIProtocol {
    func fetchContent() async throws -> [ContentItem]
}
extension ContentAPI: ContentAPIProtocol {}

// MARK: - Local Cache
protocol LocalCacheProtocol {
    func save<T: Encodable>(_ value: T, key: CacheKey)
    func load<T: Decodable>(_ type: T.Type, key: CacheKey) -> T?
    func lastUpdatedText(for key: CacheKey) -> String
}
extension LocalCache: LocalCacheProtocol {}

// MARK: - Network Status
protocol NetworkStatusProtocol {
    var isConnected: Bool { get }
}
extension NetworkMonitor: NetworkStatusProtocol {}
