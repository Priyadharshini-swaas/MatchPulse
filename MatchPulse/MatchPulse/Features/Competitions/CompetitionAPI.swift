//
//  CompetitionAPI.swift
//  MatchPulse
//
//  Extracted from CompetitionViewModel so the network layer
//  can be swapped with a mock during unit tests.
//

import Foundation
import FirebasePerformance

class CompetitionAPI {

    static let shared = CompetitionAPI()
    init() {}

    func fetchCompetitions() async throws -> [Competition] {

        let trace = AnalyticsManager.startTrace("fetch_competitions")

        guard let url = URL(string: "\(AppStrings.baseURL)/competitions") else {
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
            AnalyticsManager.logAPIFailure(endpoint: "competitions", error: "bad_server_response")
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(CompetitionResponse.self, from: data)

        guard decoded.success else {
            trace?.stop()
            throw URLError(.cannotParseResponse)
        }

        let competitions = decoded.data.competitions
        trace?.setValue(Int64(competitions.count), forMetric: "competition_count")
        trace?.stop()
        AnalyticsManager.logAPISuccess(endpoint: "competitions", itemCount: competitions.count)
        return competitions
    }
}
