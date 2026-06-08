//
//  TeamMembers.swift
//  MatchPulse
//

import SwiftUI

struct TeamMembersView: View {

    let team: TeamPlayer

    @StateObject var viewModel   = TeamViewModel()
    @State private var isFollowing = false

    var body: some View {
        VStack(spacing: 0) {

            // Offline banner
            if viewModel.isOffline {
                OfflineBanner(lastUpdated: "Cached data")
            }

            Group {
                if viewModel.isLoading {
                    TeamMembersShimmerView()

                } else if viewModel.isOffline && viewModel.players.isEmpty {
                    NoCacheOfflineView(
                        icon: "figure.soccer",
                        title: "Players Unavailable",
                        message: "View players with internet connection"
                    )

                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) { Task { await viewModel.loadPlayers(teamId: team.teamId) } }

                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            TeamHeaderView(team: team, isFollowing: $isFollowing)
                            SeasonStatsCard(season: viewModel.team.season)
                            CompetitionChipsView(competitions: viewModel.team.competitionIds)

                            HStack {
                                Text("Players").font(.title2).fontWeight(.bold).foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal)

                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.players) { player in
                                    PlayerCardView(player: player)
                                        .accessibilityIdentifier("player_card_\(player.playerId)")
                                }
                            }
                            .accessibilityIdentifier("players_list")
                            .padding(.horizontal)
                        }
                        .padding(.top)
                    }
                    .refreshable { await viewModel.loadPlayers(teamId: team.teamId) }
                }
            }
        }
        .background(Color.black)
        .navigationTitle(team.name)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadPlayers(teamId: team.teamId) }
    }
}

struct TeamHeaderView: View {
    let team: TeamPlayer
    @Binding var isFollowing: Bool
    var body: some View {
        VStack(spacing: 12) {
            AsyncImage(url: URL(string: team.logoUrl)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Circle().fill(Color(hex: "2c2c2e")).shimmer()
            }
            .frame(width: 80, height: 80)
            Text(team.name).font(.title2).fontWeight(.bold).foregroundColor(.white)
            Text(team.conference).font(.caption).foregroundColor(.white.opacity(0.7))
            Button { isFollowing.toggle() } label: {
                Text(isFollowing ? "Following" : "Follow")
                    .fontWeight(.bold).foregroundColor(.white)
                    .padding(.horizontal, 24).padding(.vertical, 8)
                    .background(isFollowing ? Color.gray : Color.blue)
                    .cornerRadius(20)
            }
        }
        .frame(maxWidth: .infinity).padding()
        .background(LinearGradient(colors: [Color(hex: team.primaryColor), Color.black], startPoint: .top, endPoint: .bottom))
        .cornerRadius(20).padding(.horizontal)
    }
}

struct PlayerCardView: View {
    let player: Players
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "figure.soccer").font(.title2).foregroundColor(.white)
                .frame(width: 44, height: 44).background(Color.gray.opacity(0.3)).clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name).font(.headline).foregroundColor(.white)
                Text(positionFullName(player.position)).font(.caption).foregroundColor(.gray)
            }
            Spacer()
            positionBadge(position: player.position)
        }
        .padding().background(Color.gray.opacity(0.15)).cornerRadius(14)
    }
    func positionBadge(position: String) -> some View {
        Text(position).font(.caption).foregroundColor(.white)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(positionColor(position)).cornerRadius(6)
    }
    func positionColor(_ p: String) -> Color {
        switch p { case "FW": return .red; case "MF": return .blue; case "DF": return .green; case "GK": return .yellow; default: return .gray }
    }
    func positionFullName(_ p: String) -> String {
        switch p { case "FW": return "Forward"; case "MF": return "Midfielder"; case "DF": return "Defender"; case "GK": return "Goalkeeper"; default: return p }
    }
}

struct SeasonStatsCard: View {
    let season: Season
    var body: some View {
        VStack(spacing: 16) {
            Text("Season Stats").font(.headline).foregroundColor(.white)
            HStack {
                statItem("W", season.wins); statItem("D", season.draws); statItem("L", season.losses)
                statItem("GF", season.goalsFor); statItem("GA", season.goalsAgainst)
            }
            HStack {
                Text("xG: \(String(format: "%.1f", season.xG))").foregroundColor(.white)
                Spacer()
                formView(season.form)
            }
        }
        .padding().background(Color.gray.opacity(0.15)).cornerRadius(16).padding(.horizontal)
    }
    func statItem(_ t: String, _ v: Int) -> some View {
        VStack { Text(t).font(.caption).foregroundColor(.gray); Text("\(v)").font(.headline).foregroundColor(.white) }.frame(maxWidth: .infinity)
    }
    func formView(_ form: String) -> some View {
        HStack(spacing: 6) {
            ForEach(Array(form), id: \.self) { c in
                Text(String(c)).font(.caption).foregroundColor(.white).frame(width: 22, height: 22).background(formColor(c)).cornerRadius(4)
            }
        }
    }
    func formColor(_ c: Character) -> Color {
        switch c { case "W": return .green; case "L": return .red; case "D": return .yellow; default: return .gray }
    }
}

struct CompetitionChipsView: View {
    let competitions: [String]
    var body: some View {
        VStack(alignment: .leading) {
            Text("Competitions").font(.headline).foregroundColor(.white).padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(competitions, id: \.self) { comp in
                        Text(comp.replacingOccurrences(of: "-", with: " ").capitalized)
                            .font(.caption).foregroundColor(.white)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.blue).cornerRadius(20)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
