//
//  TeamApi.swift
//  MatchPulse
//
//  Created by Apple on 24/04/26.
//

import Foundation
import FirebasePerformance

class TeamAPI {

    static let shared = TeamAPI()
    private init() {}

    // MARK: - Fetch Teams
    func fetchTeams() async throws -> [TeamPlayer] {

        let urlString = "\(AppStrings.baseURL)/teams"
        let trace = AnalyticsManager.startTrace("fetch_teams")

        guard let url = URL(string: urlString) else {
            trace?.stop()
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            trace?.stop()
            AnalyticsManager.logAPIFailure(endpoint: "teams", error: "bad_server_response")
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(TeamListResponse.self, from: data)
        let teams = decoded.data.teams
        trace?.setValue(Int64(teams.count), forMetric: "team_count")
        trace?.stop()
        AnalyticsManager.logAPISuccess(endpoint: "teams", itemCount: teams.count)
        return teams
    }

    // MARK: - Fetch Players
    func fetchPlayers(teamId: String) async throws -> [Players] {

        let urlString = "\(AppStrings.baseURL)/teams/\(teamId)/squad"
        let trace = AnalyticsManager.startTrace("fetch_team_players")
        trace?.setValue(teamId, forAttribute: "team_id")

        guard let url = URL(string: urlString) else {
            trace?.stop()
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            trace?.stop()
            AnalyticsManager.logAPIFailure(endpoint: "team_players", error: "bad_server_response")
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(TeamPlayersResponse.self, from: data)
        let players = decoded.data.players
        trace?.setValue(Int64(players.count), forMetric: "player_count")
        trace?.stop()
        AnalyticsManager.logAPISuccess(endpoint: "team_players", itemCount: players.count)
        return players
    }

    // MARK: - Fetch Team Details
    func fetchTeamDetails(teamId: String) async throws -> TeamDetail {

        let urlString = "\(AppStrings.baseURL)/teams/\(teamId)"
        let trace = AnalyticsManager.startTrace("fetch_team_details")
        trace?.setValue(teamId, forAttribute: "team_id")

        guard let url = URL(string: urlString) else {
            trace?.stop()
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            trace?.stop()
            AnalyticsManager.logAPIFailure(endpoint: "team_details", error: "bad_server_response")
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(TeamDetailResponse.self, from: data)
        trace?.stop()
        AnalyticsManager.logAPISuccess(endpoint: "team_details", itemCount: 1)
        return decoded.data.team
    }
}
