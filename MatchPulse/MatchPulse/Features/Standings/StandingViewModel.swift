//
//  StandingViewModel.swift
//  MatchPulse
//

import Foundation
import Combine

@MainActor
class StandingsViewModel: ObservableObject {

    @Published var standings:       [TeamStanding] = []
    @Published var competitionName: String         = ""
    @Published var season:          String         = ""
    @Published var isLoading:       Bool           = false
    @Published var errorMessage:    String?        = nil
    @Published var isOffline:       Bool           = false
    @Published var lastUpdated:     String         = ""

    private let apiService: StandingsAPIProtocol
    private let cache:      LocalCacheProtocol
    private let network:    NetworkStatusProtocol

    init(
        apiService: StandingsAPIProtocol  = StandingsAPI.shared,
        cache:      LocalCacheProtocol    = LocalCache.shared,
        network:    NetworkStatusProtocol = NetworkMonitor.shared
    ) {
        self.apiService = apiService
        self.cache      = cache
        self.network    = network
    }

    // MARK: - Fetch Standings
    func fetchStandings(competitionId: String) async {
        isLoading    = true
        errorMessage = nil

        // Strip any prefix separated by "#" (e.g. "COMP#pl-premier-league" → "pl-premier-league")
        let cleanId = competitionId.components(separatedBy: "#").last ?? competitionId
        AnalyticsManager.logStandingsViewed(competitionId: cleanId)

        if network.isConnected {
            do {
                let result      = try await apiService.fetchStandings(competitionId: cleanId)
                standings       = result.standings
                competitionName = result.competitionName
                season          = result.season
                isOffline       = false
                lastUpdated     = "Just now"
                cache.save(result, key: .standings)
            } catch {
                loadFromCache()
                AnalyticsManager.logAPIFailure(endpoint: "standings", error: error.localizedDescription)
                errorMessage = standings.isEmpty ? error.localizedDescription : nil
            }
        } else {
            loadFromCache()
        }

        isLoading = false
    }

    // MARK: - Cache Fallback
    private func loadFromCache() {
        if let cached = cache.load(StandingsData.self, key: .standings) {
            standings       = cached.standings
            competitionName = cached.competitionName
            season          = cached.season
            isOffline       = true
            lastUpdated     = cache.lastUpdatedText(for: .standings)
        } else {
            isOffline = true
            standings = []
        }
    }
}
