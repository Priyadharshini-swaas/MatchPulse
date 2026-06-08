//
//  StandingsAPI.swift
//  MatchPulse
//
//  Extracted from StandingsViewModel so the network layer
//  can be swapped with a mock during unit tests.
//

import Foundation
import FirebasePerformance

class StandingsAPI {

    static let shared = StandingsAPI()
    init() {}

    func fetchStandings(competitionId: String) async throws -> StandingsData {

        let urlString = "\(AppStrings.baseURL)/competitions/\(competitionId)/standings"
        let trace = AnalyticsManager.startTrace("fetch_standings")
        trace?.setValue(competitionId, forAttribute: "competition_id")

        guard let url = URL(string: urlString) else {
            trace?.stop()
            throw URLError(.badURL)
        }

        var request        = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            trace?.stop()
            AnalyticsManager.logAPIFailure(endpoint: "standings", error: "bad_server_response")
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(StandingsResponse.self, from: data)

        guard decoded.success else {
            trace?.stop()
            throw URLError(.cannotParseResponse)
        }

        trace?.setValue(Int64(decoded.data.standings.count), forMetric: "standing_count")
        trace?.stop()
        AnalyticsManager.logAPISuccess(endpoint: "standings", itemCount: decoded.data.standings.count)
        return decoded.data
    }
}
