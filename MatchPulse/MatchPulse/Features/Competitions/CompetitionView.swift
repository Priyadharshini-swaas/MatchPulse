//
//  CompetitionView.swift
//  MatchPulse
//

import SwiftUI

struct CompetitionGridView: View {

    @StateObject private var viewModel = CompetitionViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.isLoading {
                CompetitionShimmerGrid()

            } else if viewModel.isOffline && viewModel.competitions.isEmpty {
                NoCacheOfflineView(
                    icon: "chart.bar.fill",
                    title: "No Competitions Available",
                    message: "Open with internet once to cache competition data"
                )

            } else if let error = viewModel.errorMessage {
                ErrorView(message: error) { Task { await viewModel.fetchCompetitions() } }

            } else if viewModel.competitions.isEmpty {
                EmptyStateView(icon: "sportscourt.fill", message: "No Competitions Found")

            } else {

                VStack(spacing: 0) {

                    // Offline banner
                    if viewModel.isOffline {
                        OfflineBanner(lastUpdated: viewModel.lastUpdated)
                    }

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("All Competitions")
                                .font(.title2).fontWeight(.bold).foregroundColor(.white)
                                .accessibilityIdentifier("competitions_header")
                            Text("\(viewModel.competitions.count) competitions available")
                                .font(.caption).foregroundColor(.gray)
                                .accessibilityIdentifier("competitions_count_label")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal).padding(.top, 8)

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.competitions) { competition in
                                CompetitionCard(competition: competition)
                            }
                        }
                        .accessibilityIdentifier("competitions_grid")
                        .padding()
                    }
                    .refreshable { await viewModel.fetchCompetitions() }
                }
                .accessibilityIdentifier("competitions_screen")
            }
        }
        .onAppear { AnalyticsManager.logScreen("Competitions") }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Competitions").font(.headline).foregroundColor(.white)
                    .accessibilityIdentifier("nav_title_competitions")
            }
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: { Task { await viewModel.fetchCompetitions() } }) {
//                    Image(systemName: "arrow.clockwise").foregroundColor(.white)
//                }
//            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task { await viewModel.fetchCompetitions() }
    }
}

// MARK: - Competition Card
struct CompetitionCard: View {

    let competition: Competition

    private var gradientColors: [Color] {
        let op: Double = 0.5
        let palettes: [[Color]] = [
            [Color(hex: "FF6B6B", opacity: op), Color(hex: "FF8E53", opacity: op)],
            [Color(hex: "43CBFF", opacity: op), Color(hex: "9708CC", opacity: op)],
            [Color(hex: "0BA360", opacity: op), Color(hex: "3CBA92", opacity: op)],
            [Color(hex: "F7971E", opacity: op), Color(hex: "FFD200", opacity: op)],
            [Color(hex: "4776E6", opacity: op), Color(hex: "8E54E9", opacity: op)],
            [Color(hex: "F953C6", opacity: op), Color(hex: "B91D73", opacity: op)],
            [Color(hex: "56AB2F", opacity: op), Color(hex: "A8E063", opacity: op)],
            [Color(hex: "FF416C", opacity: op), Color(hex: "FF4B2B", opacity: op)],
            [Color(hex: "2193B0", opacity: op), Color(hex: "6DD5ED", opacity: op)],
            [Color(hex: "F7B733", opacity: op), Color(hex: "FC4A1A", opacity: op)],
        ]
        return palettes[abs(competition.competitionId.hashValue) % palettes.count]
    }

    var body: some View {
        NavigationLink {
            DarkStandingsView(competitionId: competition.competitionId)
        }label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        .opacity(0.8).frame(height: 80)
                    HStack {
                        Image(systemName: "trophy.fill").foregroundColor(.white).font(.system(size: 28)).padding(10)
                        Spacer()
                        Text(competition.season).font(.caption).fontWeight(.bold).foregroundColor(.white)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color.white.opacity(0.25)).clipShape(Capsule()).padding(10)
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(competition.competitionName).font(.subheadline).fontWeight(.bold).foregroundColor(.white).lineLimit(2)
                    HStack(spacing: 4) {
                        Image(systemName: "tag.fill").font(.caption2).foregroundColor(.gray)
                        Text(competition.competitionId.components(separatedBy: "#").last ?? "")
                            .font(.caption2).foregroundColor(.gray).lineLimit(1)
                    }
                    Rectangle()
                        .fill(LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing).opacity(0.8))
                        .frame(height: 2).clipShape(Capsule())
                }
                .padding(12).background(Color(hex: "1c1c1e"))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.07), lineWidth: 1))
        .shadow(color: gradientColors[0].opacity(0.5), radius: 10, x: 0, y: 5)
        .accessibilityIdentifier("competition_card_\(competition.competitionId)")
    }
}
