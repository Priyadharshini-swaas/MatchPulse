//
//  MatchDetailViewModel.swift
//  MatchPulse
//

import Foundation
import SwiftUI
import Combine

@MainActor
class MatchDetailsViewModel: ObservableObject {

    @Published var match:        MatchDetails?   = nil
    @Published var events:       [MatchEvent]    = []
    @Published var isLoading:    Bool            = false
    @Published var errorMessage: String?         = nil

    private let apiService: MatchDetailsAPIProtocol

    init(apiService: MatchDetailsAPIProtocol = MatchDetailsAPI.shared) {
        self.apiService = apiService
    }

    // MARK: - Load Match Details
    func load(matchId: String) async {
        isLoading    = true
        errorMessage = nil
        do {
            let data = try await apiService.fetchMatchDetails(matchId: matchId)
            match    = data.match
            events   = data.events
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
