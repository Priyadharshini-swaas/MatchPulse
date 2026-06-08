//
//  MatchCardView.swift
//  MatchPulse
//

import Foundation
import SwiftUI

// MARK: - HomeScreen Tab Root
struct HomeScreen: View {

    @StateObject private var locationManager = LocationManager()

    var body: some View {
        TabView {
            NavigationStack { HomeContentView() }
                .tabItem { Image(systemName: "house"); Text("Home") }
                .accessibilityIdentifier("tab_home")

            NavigationStack { MatchesView() }
                .tabItem { Image(systemName: "dot.radiowaves.left.and.right"); Text("Live") }
                .accessibilityIdentifier("tab_live")

            NavigationStack { TeamSliderView() }
                .tabItem { Image(systemName: "person.3.sequence"); Text("Team") }
                .accessibilityIdentifier("tab_team")

            NavigationStack { CompetitionGridView() }
                .tabItem { Image(systemName: "chart.bar.fill"); Text("Competitions") }
                .accessibilityIdentifier("tab_competitions")

            NavigationStack { ProfilePlaceholderView() }
                .tabItem { Image(systemName: "person.circle.fill"); Text("Profile") }
                .accessibilityIdentifier("tab_profile")
        }
        .accessibilityIdentifier("main_tab_bar")
        .background(Color.black)
        .onAppear { requestPermissions() }
    }

    private func requestPermissions() {
        locationManager.requestLocationPermission()
        NotificationManager.requestPermission()
    }
}

// MARK: - Profile Placeholder
struct ProfilePlaceholderView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "person.circle.fill").font(.system(size: 60)).foregroundColor(.gray)
                Text("Profile").foregroundColor(.gray).font(.headline)
                    .accessibilityIdentifier("profile_title")
                Text("Coming Soon").foregroundColor(.gray.opacity(0.6)).font(.caption)
                    .accessibilityIdentifier("profile_coming_soon")
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Profile").foregroundStyle(Color.white).font(.system(size: 20, weight: .semibold))
                    .accessibilityIdentifier("nav_title_profile")
            }
        }
        .toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Matches View
struct MatchesView: View {

    @StateObject var viewModel = MatchViewModel()

    var body: some View {
        VStack(spacing: 0) {

            // Offline banner
            if viewModel.isOffline && !viewModel.matches.isEmpty {
                OfflineBanner(lastUpdated: viewModel.lastUpdated)
            }

            Group {
                if viewModel.isLoading {
                    MatchListShimmerView()

                } else if viewModel.isOffline && viewModel.matches.isEmpty {
                    NoCacheOfflineView(
                        icon: "dot.radiowaves.left.and.right",
                        title: "No Live Matches",
                        message: "Open with internet once to cache match data"
                    )

                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) { Task { await viewModel.loadMatches() } }

                } else if viewModel.matches.isEmpty {
                    EmptyStateView(icon: "dot.radiowaves.left.and.right", message: "No live matches right now")

                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.matches) { match in
                                MatchCardView(match: match)
                                    .padding(.horizontal)
                                    .accessibilityIdentifier("match_card_\(match.matchId)")
                            }
                        }
                        .padding(.vertical)
                        .accessibilityIdentifier("match_list")
                    }
                    .refreshable { await viewModel.loadMatches() }
                }
            }
        }
        .accessibilityIdentifier("live_screen")
        .background(Color.black)
        .task {
            await viewModel.loadMatches()
            AnalyticsManager.logScreen("LiveMatches")
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Live").foregroundStyle(Color.white).font(.system(size: 20, weight: .semibold))
                    .accessibilityIdentifier("nav_title_live")
            }
        }
        .toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Match Card
struct MatchCardView: View {

    let match: Match

    var gradientBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: match.homeTeam.primaryColor ?? "#1E1E1E"),
                Color(hex: match.awayTeam.primaryColor ?? "#444444")
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        NavigationLink(destination: MatchDetailsView(matchId: match.matchId)) {
            VStack(spacing: 16) {
                HStack {
                    if match.status == "LIVE" {
                        Text("LIVE \(match.minute)'")
                            .font(.caption).bold().foregroundColor(.white)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.red).cornerRadius(6)
                    }
                    Spacer()
                }
                HStack {
                    TeamView(team: match.homeTeam)
                    Spacer()
                    Text("\(match.homeScore) - \(match.awayScore)")
                        .font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                    Spacer()
                    TeamView(team: match.awayTeam)
                }
                Divider().background(Color.white.opacity(0.4))
                HStack {
                    Text(match.venue.name).font(.caption).foregroundColor(.white.opacity(0.9))
                    Spacer()
                    Text(match.venue.city).font(.caption).foregroundColor(.white.opacity(0.9))
                }
            }
            .padding()
            .background(gradientBackground.opacity(0.5))
            .cornerRadius(16)
            .shadow(radius: 4)
        }
    }
}

// MARK: - Shared Error View
struct ErrorView: View {
    let message: String
    let retry: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 48)).foregroundColor(.orange)
                .accessibilityIdentifier("error_icon")
            Text(message).foregroundColor(.gray).multilineTextAlignment(.center).padding(.horizontal)
                .accessibilityIdentifier("error_message")
            Button("Retry") { retry() }
                .foregroundColor(.black).padding(.horizontal, 32).padding(.vertical, 12)
                .background(Color.white).clipShape(Capsule())
                .accessibilityIdentifier("retry_button")
            Spacer()
        }
        .accessibilityIdentifier("error_view")
        .frame(maxWidth: .infinity).background(Color.black)
    }
}

// MARK: - Shared Empty State View
struct EmptyStateView: View {
    let icon: String
    let message: String
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: icon).font(.system(size: 48)).foregroundColor(.gray)
            Text(message).foregroundColor(.gray).font(.headline)
                .accessibilityIdentifier("empty_state_message")
            Spacer()
        }
        .accessibilityIdentifier("empty_state_view")
        .frame(maxWidth: .infinity).background(Color.black)
    }
}
