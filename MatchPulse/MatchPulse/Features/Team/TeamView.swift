//
//  TeamView.swift
//  MatchPulse
//

import Foundation
import SwiftUI

struct TeamSliderView: View {

    @StateObject var viewModel = TeamViewModel()

    var body: some View {
        VStack(spacing: 0) {

            // Offline banner
            if viewModel.isOffline && !viewModel.teams.isEmpty {
                OfflineBanner(lastUpdated: viewModel.lastUpdated)
            }

            Group {
                if viewModel.isLoading {
                    TeamSliderShimmerView()

                } else if viewModel.isOffline && viewModel.teams.isEmpty {
                    NoCacheOfflineView(
                        icon: "person.3.sequence",
                        title: "No Teams Available",
                        message: "Open with internet once to cache team data"
                    )

                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) { Task { await viewModel.loadTeams() } }

                } else if viewModel.teams.isEmpty {
                    EmptyStateView(icon: "person.3.sequence", message: "No Teams Found")

                } else {
                    RefreshableTeamSlider(viewModel: viewModel)
                }
            }
        }
        .background(Color.black)
        .ignoresSafeArea()
        .task {
            await viewModel.loadTeams()
            AnalyticsManager.logScreen("Teams")
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Teams").foregroundStyle(Color.white).font(.system(size: 20, weight: .semibold))
                    .accessibilityIdentifier("nav_title_teams")
            }
        }
        .toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RefreshableTeamSlider: View {

    @ObservedObject var viewModel: TeamViewModel

    var body: some View {
        ScrollView {
            TabView {
                ForEach(viewModel.teams, id: \.id) { team in
                    TeamCardView(team: team)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .frame(height: 850)
        }
        .refreshable { await viewModel.loadTeams() }
        .background(Color.black)
        .ignoresSafeArea()
    }
}

struct TeamCardView: View {

    let team: TeamPlayer

    var body: some View {
        VStack(spacing: 12) {
            AsyncImage(url: URL(string: team.logoUrl)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Circle().fill(Color(hex: "2c2c2e")).shimmer()
            }
            .frame(width: 200, height: 200)

            Text(team.name).font(.headline).foregroundColor(.white)
            Text(team.conference).font(.caption).foregroundColor(.white.opacity(0.7))
            PlayersNavigationCard(team: team)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(colors: [Color(hex: team.primaryColor), Color.black], startPoint: .topLeading, endPoint: .bottomTrailing))
        .ignoresSafeArea()
        .cornerRadius(18)
        .padding(.horizontal)
    }
}

struct PlayersNavigationCard: View {

    let team: TeamPlayer

    var body: some View {
        NavigationLink {
            TeamMembersView(team: team)
        } label: {
            HStack {
                Image(systemName: "person.3.fill").foregroundColor(.white)
                Text("View Players").font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.5)))
        }
        .accessibilityIdentifier("view_players_button_\(team.teamId)")
        .padding(.horizontal)
    }
}
