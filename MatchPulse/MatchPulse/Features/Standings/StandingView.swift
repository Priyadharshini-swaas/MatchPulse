//
//  StandingView.swift
//  MatchPulse
//
//  Created by Apple on 05/05/26.
//

import Foundation
import SwiftUI

import SwiftUI

struct StandingsView: View {
    let competitionId : String
    @StateObject private var viewModel = StandingsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            headerView
            
            // Table Header
            tableHeader
            
            // List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.standings.sorted(by: { $0.position < $1.position })) { team in
                        StandingCard(team: team)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.black))
        .task {
            await viewModel.fetchStandings(competitionId: competitionId)
        }
    }
}
extension StandingsView {
    
    var headerView: some View {
        VStack(spacing: 4) {
            Text("MLS Standings")
                .font(.title2.bold())
            
            Text("2026 Season")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}
extension StandingsView {
    
    var tableHeader: some View {
        HStack {
            Text("#").frame(width: 30)
            Text("Team").frame(maxWidth: .infinity, alignment: .leading)
            Text("P")
            Text("GD")
            Text("Pts")
        }
        .font(.caption.bold())
        .foregroundColor(.gray)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
}
struct StandingCard: View {
    
    let team: TeamStanding
    
    var body: some View {
        HStack(spacing: 12) {
            
            // Position
            Text("\(team.position)")
                .font(.headline)
                .frame(width: 30)
                .foregroundColor(rankColor)
            
            // Logo + Name
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(shortName)
                            .font(.caption.bold())
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(shortName)
                        .font(.headline)
                    
                    Text("W\(team.wins) D\(team.draws) L\(team.losses)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Played
            Text("\(team.wins + team.draws + team.losses)")
                .frame(width: 30)
            
            // Goal Difference
            Text("\(team.goalDifference)")
                .frame(width: 40)
                .foregroundColor(goalDiffColor)
            
            // Points
            Text("\(team.points)")
                .frame(width: 40)
                .font(.headline)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
}
extension StandingCard {
    
    var shortName: String {
        team.shortName?.isEmpty == false
        ? team.shortName!
        : team.teamId.replacingOccurrences(of: "TEAM#", with: "").uppercased()
    }
    
    var goalDiffColor: Color {
        if team.goalDifference > 0 { return .green }
        if team.goalDifference < 0 { return .red }
        return .gray
    }
    
    var rankColor: Color {
        switch team.position {
        case 1: return .green
        case 2...4: return .blue
        default: return .primary
        }
    }
}
func formColor(_ result: String) -> Color {
    switch result {
    case "W": return .green
    case "L": return .red
    case "D": return .orange
    default: return .gray
    }
}
struct DarkStandingsView: View {
    let competitionId : String
    @StateObject private var viewModel = StandingsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            HStack {
                Text("Standings")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color.black)
            
            // Table Header
            HStack {
                Text("#").frame(width: 28)
                Text("Team")
                Spacer()
                Text("P")
                Text("GD")
                Text("Pts")
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(Color.black)
            
            // List
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.standings.sorted(by: { $0.position < $1.position })) { team in
                        DarkStandingCard(team: team)
                            .accessibilityIdentifier("standing_row_\(team.position)")
                    }
                }
                .accessibilityIdentifier("standings_list")
            }
        }
        .accessibilityIdentifier("standings_screen")
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black.ignoresSafeArea())
        .task {
            AnalyticsManager.logScreen("Standings")
            await viewModel.fetchStandings(competitionId: competitionId)
        }
    }
}
extension DarkStandingCard {
    
    var shortName: String {
        team.shortName?.isEmpty == false
        ? team.shortName!
        : team.teamId.replacingOccurrences(of: "TEAM#", with: "").uppercased()
    }
    
    var played: Int {
        team.wins + team.draws + team.losses
    }
    
    var goalDiffFormatted: String {
        "\(team.goalDifference > 0 ? "+" : "")\(team.goalDifference)"
    }
    
    var goalDiffColor: Color {
        if team.goalDifference > 0 { return .green }
        if team.goalDifference < 0 { return .red }
        return .gray
    }
    
    var rankColor: Color {
        switch team.position {
        case 1: return .green
        case 2...4: return .blue
        default: return .white
        }
    }
    
    func statText(_ text: String, color: Color = .white) -> some View {
        Text(text)
            .font(.subheadline)
            .frame(width: 28)
            .foregroundColor(color)
    }
}

struct DarkStandingCard: View {
    
    let team: TeamStanding
    
    var body: some View {
        HStack(spacing: 12) {
            
            // Position
            Text("\(team.position)")
                .font(.headline.bold())
                .frame(width: 28)
                .foregroundColor(rankColor)
            
            // Team Info
            HStack(spacing: 10) {
                
                // Logo placeholder
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(shortName.prefix(2))
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(shortName)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    
                    Text("W\(team.wins) D\(team.draws) L\(team.losses)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Stats
            HStack(spacing: 14) {
                
                statText("\(played)")
                statText(goalDiffFormatted, color: goalDiffColor)
                
                // Points Highlight
                Text("\(team.points)")
                    .font(.subheadline.bold())
                    .frame(width: 36, height: 28)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color.black)
        .overlay(
            Divider()
                .background(Color.white.opacity(0.1)),
            alignment: .bottom
        )
    }
}
