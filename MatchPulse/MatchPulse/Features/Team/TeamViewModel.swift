//
//  TeamViewModel.swift
//  MatchPulse
//

import Foundation
import Combine

@MainActor
class TeamViewModel: ObservableObject {

    @Published var teams:        [TeamPlayer]  = []
    @Published var players:      [Players]     = []
    @Published var team:         TeamDetail    = TeamDetail()
    @Published var isLoading:    Bool          = false
    @Published var errorMessage: String?       = nil
    @Published var isOffline:    Bool          = false
    @Published var lastUpdated:  String        = ""

    private let apiService: TeamAPIProtocol
    private let cache:      LocalCacheProtocol
    private let network:    NetworkStatusProtocol

    init(
        apiService: TeamAPIProtocol       = TeamAPI.shared,
        cache:      LocalCacheProtocol    = LocalCache.shared,
        network:    NetworkStatusProtocol = NetworkMonitor.shared
    ) {
        self.apiService = apiService
        self.cache      = cache
        self.network    = network
    }

    // MARK: - Load Teams
    func loadTeams() async {
        isLoading    = true
        errorMessage = nil

        if network.isConnected {
            do {
                let fetched = try await apiService.fetchTeams()
                teams       = fetched
                isOffline   = false
                cache.save(fetched, key: .teams)
                lastUpdated = "Just now"
            } catch {
                loadTeamsFromCache()
                errorMessage = teams.isEmpty ? error.localizedDescription : nil
            }
        } else {
            loadTeamsFromCache()
        }

        isLoading = false
    }

    private func loadTeamsFromCache() {
        if let cached = cache.load([TeamPlayer].self, key: .teams) {
            teams       = cached
            isOffline   = true
            lastUpdated = cache.lastUpdatedText(for: .teams)
        } else {
            isOffline = true
            teams     = []
        }
    }

    // MARK: - Load Players + Team Details
    func loadPlayers(teamId: String) async {
        isLoading    = true
        errorMessage = nil

        if network.isConnected {
            do {
                async let playersResult    = apiService.fetchPlayers(teamId: teamId)
                async let teamDetailResult = apiService.fetchTeamDetails(teamId: teamId)
                players   = try await playersResult
                team      = try await teamDetailResult
                isOffline = false
            } catch {
                errorMessage = error.localizedDescription
                isOffline    = true
            }
        } else {
            isOffline = true
            if players.isEmpty {
                errorMessage = nil
            }
        }

        isLoading = false
    }
}
