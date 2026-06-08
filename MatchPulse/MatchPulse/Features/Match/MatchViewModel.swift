//
//  MatchViewModel.swift
//  MatchPulse
//

import Foundation
import SwiftUI
import Combine

@MainActor
class MatchViewModel: ObservableObject {

    @Published var matches: [Match]      = []
    @Published var isLoading             = false
    @Published var errorMessage: String? = nil
    @Published var isOffline             = false
    @Published var lastUpdated           = ""

    private let apiService: MatchAPIServiceProtocol
    private let cache:      LocalCacheProtocol
    private let network:    NetworkStatusProtocol

    init(
        apiService: MatchAPIServiceProtocol = MatchAPIService.shared,
        cache:      LocalCacheProtocol      = LocalCache.shared,
        network:    NetworkStatusProtocol   = NetworkMonitor.shared
    ) {
        self.apiService = apiService
        self.cache      = cache
        self.network    = network
    }

    // MARK: - Load Matches
    func loadMatches() async {
        isLoading    = true
        errorMessage = nil

        if network.isConnected {
            do {
                let fetched = try await apiService.fetchMatches()
                matches     = fetched
                isOffline   = false
                cache.save(fetched, key: .matches)
                lastUpdated = "Just now"
            } catch {
                loadFromCache()
                errorMessage = matches.isEmpty ? error.localizedDescription : nil
            }
        } else {
            loadFromCache()
        }

        isLoading = false
    }

    private func loadFromCache() {
        if let cached = cache.load([Match].self, key: .matches) {
            matches     = cached
            isOffline   = true
            lastUpdated = cache.lastUpdatedText(for: .matches)
        } else {
            isOffline = true
            matches   = []
        }
    }
}
