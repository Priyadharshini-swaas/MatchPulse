//
//  MatchDetailsAPI.swift
//  MatchPulse
//
//  Created by Apple on 21/04/26.
//

import Foundation
import FirebasePerformance

class MatchDetailsAPI {

    static let shared = MatchDetailsAPI()
    private init() {}

    // MARK: - async/await
    func fetchMatchDetails(matchId: String) async throws -> MatchDetailsData {

        let urlString = "\(AppStrings.baseURL)/matches/\(matchId)"
        let trace = AnalyticsManager.startTrace("fetch_match_details")
        trace?.setValue(matchId, forAttribute: "match_id")

        guard let url = URL(string: urlString) else {
            trace?.stop()
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            trace?.stop()
            AnalyticsManager.logAPIFailure(endpoint: "match_details", error: "bad_server_response")
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(MatchDetailsResponse.self, from: data)
        trace?.stop()
        AnalyticsManager.logAPISuccess(endpoint: "match_details", itemCount: 1)
        return decoded.data
    }
}
