//
//  ContentViewModel.swift
//  MatchPulse
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ContentViewModel: ObservableObject {

    @Published var items:        [ContentItem] = []
    @Published var isLoading:    Bool          = false
    @Published var errorMessage: String?       = nil
    @Published var isOffline:    Bool          = false
    @Published var lastUpdated:  String        = ""

    private let apiService: ContentAPIProtocol
    private let cache:      LocalCacheProtocol
    private let network:    NetworkStatusProtocol

    init(
        apiService: ContentAPIProtocol    = ContentAPI.shared,
        cache:      LocalCacheProtocol    = LocalCache.shared,
        network:    NetworkStatusProtocol = NetworkMonitor.shared
    ) {
        self.apiService = apiService
        self.cache      = cache
        self.network    = network
    }

    // MARK: - Load Content
    func loadContent() async {
        isLoading    = true
        errorMessage = nil

        if network.isConnected {
            do {
                let fetched = try await apiService.fetchContent()
                items       = fetched
                isOffline   = false
                cache.save(fetched, key: .content)
                lastUpdated = "Just now"
            } catch {
                loadFromCache()
                errorMessage = items.isEmpty ? error.localizedDescription : nil
            }
        } else {
            loadFromCache()
        }

        isLoading = false
    }

    // MARK: - Cache Fallback
    private func loadFromCache() {
        if let cached = cache.load([ContentItem].self, key: .content) {
            items       = cached
            isOffline   = true
            lastUpdated = cache.lastUpdatedText(for: .content)
        } else {
            isOffline = true
            items     = []
        }
    }
}
