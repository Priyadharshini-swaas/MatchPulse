//
//  MatchDetailsView.swift
//  MatchPulse
//

import Foundation
import SwiftUI

// MARK: - Match Details View
struct MatchDetailsView: View {

    let matchId: String
    @StateObject var viewModel = MatchDetailsViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                MatchDetailsShimmerView()

            } else if let error = viewModel.errorMessage {
                ErrorView(message: error) { Task { await viewModel.load(matchId: matchId) } }

            } else if let match = viewModel.match {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        MatchHeaderView(match: match)

                        if match.lineup.home.count > 0 || match.lineup.away.count > 0 {
                            LineupView(lineup: match)
                        }

                        EventsView(events: viewModel.events)
                    }
                }
                // Pull to refresh
                .refreshable { await viewModel.load(matchId: matchId) }
            }
        }
        .accessibilityIdentifier("match_details_screen")
        .background(Color.black)
        .navigationTitle("Match Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { Task { await viewModel.load(matchId: matchId) } }) {
                    Image(systemName: "arrow.clockwise").foregroundColor(.white)
                }
            }
        }
        .toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            await viewModel.load(matchId: matchId)
            AnalyticsManager.logScreen("MatchDetails")
            AnalyticsManager.logMatchDetailsViewed(matchId: matchId)
        }
    }
}

// MARK: - Events View
struct EventsView: View {

    let events: [MatchEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MATCH EVENTS")
                .foregroundColor(.white).font(.headline)

            if events.isEmpty {
                Text("No events yet").foregroundColor(.gray).font(.caption).padding(.top, 4)
            } else {
                ForEach(events) { event in
                    HStack(spacing: 12) {
                        Text("\(event.minute)'")
                            .foregroundColor(.gray).frame(width: 36, alignment: .leading)
                        Image(systemName: eventIcon(event.type))
                            .foregroundColor(eventColor(event.type))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(event.playerName).foregroundColor(.white)
                            Text(event.description).foregroundColor(.gray).font(.caption)
                        }
                    }
                    .padding(.vertical, 6)
                    Divider().background(Color.white.opacity(0.07))
                }
            }
        }
        .padding()
    }

    private func eventIcon(_ type: String) -> String {
        switch type {
        case "GOAL":   return "soccerball"
        case "YELLOW": return "rectangle.fill"
        case "RED":    return "rectangle.fill"
        case "SUB":    return "arrow.left.arrow.right"
        default:       return "circle.fill"
        }
    }

    private func eventColor(_ type: String) -> Color {
        switch type {
        case "GOAL":   return .green
        case "YELLOW": return .yellow
        case "RED":    return .red
        case "SUB":    return .blue
        default:       return .gray
        }
    }
}

// MARK: - Player Column
struct PlayerColumn: View {

    let title: String
    let players: [Player]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).foregroundColor(.white).font(.headline).padding(.bottom, 4)
            ForEach(players) { player in
                HStack {
                    Text("\(player.number)").foregroundColor(.gray).frame(width: 24)
                    Text(player.name).foregroundColor(.white).font(.subheadline)
                    Spacer()
                    Text(player.position).foregroundColor(.gray).font(.caption)
                }
                .padding(.vertical, 3)
            }
        }
    }
}

// MARK: - Lineup View
struct LineupView: View {

    let lineup: MatchDetails

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LINEUPS").foregroundColor(.white).font(.headline).padding(.horizontal)

            HStack(alignment: .top) {
                PlayerColumn(title: lineup.homeTeam.shortName, players: lineup.lineup.home)
                Spacer()
                PlayerColumn(title: lineup.awayTeam.shortName, players: lineup.lineup.away)
            }
            .padding()
            .background(Color(hex: "1c1c1e"))
            .cornerRadius(14)
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Team Logo View
struct TeamLogoView: View {

    let team: Teams

    var body: some View {
        VStack {
            if !team.logoUrl.isEmpty, let url = URL(string: team.logoUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Circle().fill(Color(hex: "2c2c2e")).shimmer()
                }
                .frame(width: 60, height: 60)
            } else {
                Image(systemName: "sportscourt")
                    .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.gray)
            }
            Text(team.shortName).foregroundColor(.white).font(.headline)
        }
        .frame(width: 70)
    }
}

// MARK: - Match Header View
struct MatchHeaderView: View {

    let match: MatchDetails

    var gradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: match.homeTeam.primaryColor ?? "#000000"),
                Color(hex: match.awayTeam.primaryColor ?? "#333333")
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                TeamLogoView(team: match.homeTeam)
                Spacer()
                VStack {
                    Text("\(match.homeScore) - \(match.awayScore)")
                        .font(.system(size: 34, weight: .bold)).foregroundColor(.white)
                    if match.status == "LIVE" {
                        Text("LIVE").foregroundColor(.red).font(.caption)
                    }
                }
                Spacer()
                TeamLogoView(team: match.awayTeam)
            }
            Text(match.venue.name).foregroundColor(.white.opacity(0.8)).font(.caption)
        }
        .padding()
        .background(gradient.opacity(0.5))
        .cornerRadius(18)
        .padding()
    }
}
