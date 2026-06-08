//
//  TestFixtures.swift
//  MatchPulseTests
//
//  Factory helpers that create model instances via JSON decoding.
//  Because every model uses custom init(from:) with decodeIfPresent,
//  a minimal JSON object is enough — missing fields fall back to defaults.
//

import Foundation
@testable import MatchPulse

// MARK: - Match

enum TestFixtures {

    // MARK: Match

    static func match(
        matchId:   String = "match-001",
        homeTeam:  String = "LAFC",
        awayTeam:  String = "NYCFC",
        homeScore: Int    = 1,
        awayScore: Int    = 0,
        status:    String = "LIVE",
        minute:    Int    = 45
    ) -> Match {
        let json = """
        {
            "matchId":      "\(matchId)",
            "homeTeam":     { "id": "t1", "name": "\(homeTeam)", "shortName": "LAF", "logoUrl": "", "primaryColor": "#FF0000" },
            "awayTeam":     { "id": "t2", "name": "\(awayTeam)", "shortName": "NYC", "logoUrl": "", "primaryColor": "#0000FF" },
            "homeScore":    \(homeScore),
            "awayScore":    \(awayScore),
            "status":       "\(status)",
            "kickoffUtc":   "2026-06-01T20:00:00Z",
            "minute":       \(minute),
            "competitionId":"comp-001",
            "venue":        { "name": "Banc of California Stadium", "city": "Los Angeles" }
        }
        """
        return try! JSONDecoder().decode(Match.self, from: json.data(using: .utf8)!)
    }

    // MARK: MatchEvent

    static func matchEvent(
        eventId:    String = "ev-001",
        type:       String = "GOAL",
        minute:     Int    = 23,
        playerName: String = "Vela"
    ) -> MatchEvent {
        let json = """
        {
            "eventId":    "\(eventId)",
            "type":       "\(type)",
            "minute":     \(minute),
            "teamId":     "t1",
            "playerId":   "p1",
            "playerName": "\(playerName)",
            "description":"Header goal"
        }
        """
        return try! JSONDecoder().decode(MatchEvent.self, from: json.data(using: .utf8)!)
    }

    // MARK: MatchDetailsData

    static func matchDetailsData(matchId: String = "match-001") -> MatchDetailsData {
        let json = """
        {
            "match": {
                "matchId":         "\(matchId)",
                "homeTeam":        { "id": "t1", "name": "LAFC", "shortName": "LAF", "logoUrl": "" },
                "awayTeam":        { "id": "t2", "name": "NYCFC","shortName": "NYC", "logoUrl": "" },
                "homeScore":       2,
                "awayScore":       1,
                "status":          "LIVE",
                "kickoffUtc":      "2026-06-01T20:00:00Z",
                "minute":          67,
                "competitionName": "MLS",
                "venue":           { "name": "Banc of California Stadium", "city": "Los Angeles" },
                "lineup":          { "home": [], "away": [] }
            },
            "stats":  {},
            "events": []
        }
        """
        return try! JSONDecoder().decode(MatchDetailsData.self, from: json.data(using: .utf8)!)
    }

    // MARK: TeamPlayer

    static func teamPlayer(
        id:   String = "team#t1",
        name: String = "LA FC"
    ) -> TeamPlayer {
        let json = """
        {
            "id":           "\(id)",
            "name":         "\(name)",
            "shortName":    "LAF",
            "conference":   "Western",
            "logoUrl":      "https://example.com/logo.png",
            "primaryColor": "#000000"
        }
        """
        return try! JSONDecoder().decode(TeamPlayer.self, from: json.data(using: .utf8)!)
    }

    // MARK: Players (squad member)

    static func player(
        playerId: String = "p1",
        name:     String = "Carlos Vela",
        position: String = "FW"
    ) -> Players {
        let json = """
        {
            "playerId": "\(playerId)",
            "name":     "\(name)",
            "position": "\(position)"
        }
        """
        return try! JSONDecoder().decode(Players.self, from: json.data(using: .utf8)!)
    }

    // MARK: TeamDetail

    static func teamDetail(
        teamId: String = "team#t1",
        name:   String = "LA FC"
    ) -> TeamDetail {
        let json = """
        {
            "teamId":       "\(teamId)",
            "name":         "\(name)",
            "shortName":    "LAF",
            "conference":   "Western",
            "logoUrl":      "",
            "primaryColor": "#000000",
            "season":       { "wins": 10, "draws": 3, "losses": 2, "goalsFor": 30, "goalsAgainst": 12, "xG": 28.5, "form": "WWDLW" },
            "competitionIds": ["comp-001"]
        }
        """
        return try! JSONDecoder().decode(TeamDetail.self, from: json.data(using: .utf8)!)
    }

    // MARK: TeamStanding

    static func teamStanding(
        position: Int    = 1,
        teamId:   String = "t1",
        teamName: String = "LA FC",
        points:   Int    = 33
    ) -> TeamStanding {
        let json = """
        {
            "position":       \(position),
            "teamId":         "\(teamId)",
            "teamName":       "\(teamName)",
            "shortName":      "LAF",
            "logoUrl":        "",
            "played":         15,
            "wins":           10,
            "draws":          3,
            "losses":         2,
            "goalsFor":       30,
            "goalsAgainst":   12,
            "goalDifference": 18,
            "points":         \(points),
            "form":           "WWDLW"
        }
        """
        return try! JSONDecoder().decode(TeamStanding.self, from: json.data(using: .utf8)!)
    }

    // MARK: StandingsData

    static func standingsData(count: Int = 3) -> StandingsData {
        let teamStandingsJSON = (1...count).map { i in
        """
        {
            "position": \(i), "teamId": "t\(i)", "teamName": "Team \(i)",
            "shortName": "T\(i)", "logoUrl": "", "played": 15,
            "wins": \(10 - i), "draws": 2, "losses": \(i),
            "goalsFor": 20, "goalsAgainst": 10, "goalDifference": 10,
            "points": \(33 - i * 3), "form": "WWWDD"
        }
        """
        }.joined(separator: ",")

        let json = """
        {
            "competitionId":   "comp-001",
            "competitionName": "MLS",
            "season":          "2026",
            "standings":       [\(teamStandingsJSON)]
        }
        """
        return try! JSONDecoder().decode(StandingsData.self, from: json.data(using: .utf8)!)
    }

    // MARK: Competition

    static func competition(
        id:   String = "comp-001",
        name: String = "MLS",
        season: String = "2026"
    ) -> Competition {
        let json = """
        {
            "competitionId":   "\(id)",
            "competitionName": "\(name)",
            "season":          "\(season)"
        }
        """
        return try! JSONDecoder().decode(Competition.self, from: json.data(using: .utf8)!)
    }

    // MARK: ContentItem

    static func contentItem(
        contentId: String = "c1",
        headline:  String = "LAFC Win 3-0",
        type:      String = "video"
    ) -> ContentItem {
        let json = """
        {
            "contentId":    "\(contentId)",
            "type":         "\(type)",
            "headline":     "\(headline)",
            "summary":      "Match summary",
            "publishedAt":  "2026-06-01T22:00:00Z",
            "thumbnailUrl": "https://example.com/thumb.jpg",
            "contentUrl":   "https://example.com/video.mp4",
            "tags":         ["MLS", "LAFC"]
        }
        """
        return try! JSONDecoder().decode(ContentItem.self, from: json.data(using: .utf8)!)
    }

    // MARK: Errors

    static var networkError: Error {
        URLError(.notConnectedToInternet)
    }

    static var serverError: Error {
        URLError(.badServerResponse)
    }
}
