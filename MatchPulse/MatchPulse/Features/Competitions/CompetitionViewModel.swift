//
//  CompetitionViewModel.swift
//  MatchPulse
//

import Foundation
import Combine

@MainActor
class CompetitionViewModel: ObservableObject {

    @Published var competitions: [Competition] = []
    @Published var isLoading:    Bool          = false
    @Published var errorMessage: String?       = nil
    @Published var isOffline:    Bool          = false
    @Published var lastUpdated:  String        = ""

    private let apiService: CompetitionAPIProtocol
    private let cache:      LocalCacheProtocol
    private let network:    NetworkStatusProtocol

    init(
        apiService: CompetitionAPIProtocol = CompetitionAPI.shared,
        cache:      LocalCacheProtocol     = LocalCache.shared,
        network:    NetworkStatusProtocol  = NetworkMonitor.shared
    ) {
        self.apiService = apiService
        self.cache      = cache
        self.network    = network
    }

    // MARK: - Fetch Competitions
    func fetchCompetitions() async {
        isLoading    = true
        errorMessage = nil

        if network.isConnected {
            do {
                let fetched  = try await apiService.fetchCompetitions()
                competitions = fetched
                isOffline    = false
                cache.save(fetched, key: .competitions)
                lastUpdated  = "Just now"
            } catch {
                loadFromCache()
                AnalyticsManager.logAPIFailure(endpoint: "competitions", error: error.localizedDescription)
                errorMessage = competitions.isEmpty ? error.localizedDescription : nil
            }
        } else {
            loadFromCache()
        }

        isLoading = false
    }

    // MARK: - Cache Fallback
    private func loadFromCache() {
        if let cached = cache.load([Competition].self, key: .competitions) {
            competitions = cached
            isOffline    = true
            lastUpdated  = cache.lastUpdatedText(for: .competitions)
        } else {
            isOffline    = true
            competitions = []
        }
    }
}
