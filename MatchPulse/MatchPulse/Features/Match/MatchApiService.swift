//
//  MatchApiService.swift
//  MatchPulse
//
//  Created by Apple on 21/04/26.
//

import Foundation
import FirebasePerformance

class MatchAPIService {

    static let shared = MatchAPIService()
    private init() {}

    // MARK: - Fetch Live Matches
    func fetchMatches() async throws -> [Match] {

        let urlString = "\(AppStrings.baseURL)/matches/live?limit=20"
        let trace = AnalyticsManager.startTrace("fetch_live_matches")

        guard let url = URL(string: urlString) else {
            trace?.stop()
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            trace?.stop()
            AnalyticsManager.logAPIFailure(endpoint: "live_matches", error: "bad_server_response")
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(MatchResponse.self, from: data)
        let matches = decoded.data.matches
        trace?.setValue(Int64(matches.count), forMetric: "match_count")
        trace?.stop()
        AnalyticsManager.logAPISuccess(endpoint: "live_matches", itemCount: matches.count)
        return matches
    }

    // MARK: - Fetch Match Events
    func fetchMatchEvents(matchId: String) async throws -> [MatchEvent] {

        let urlString = "\(AppStrings.baseURL)/matches/\(matchId)/events?limit=50"
        let trace = AnalyticsManager.startTrace("fetch_match_events")
        trace?.setValue(matchId, forAttribute: "match_id")

        guard let url = URL(string: urlString) else {
            trace?.stop()
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            trace?.stop()
            AnalyticsManager.logAPIFailure(endpoint: "match_events", error: "bad_server_response")
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(MatchEventsResponse.self, from: data)
        let events = decoded.data.events
        trace?.setValue(Int64(events.count), forMetric: "event_count")
        trace?.stop()
        AnalyticsManager.logAPISuccess(endpoint: "match_events", itemCount: events.count)
        return events
    }
}
