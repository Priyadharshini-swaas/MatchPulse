//
//  matchdetailsModel.swift
//  MatchPulse
//
//  Created by Apple on 21/04/26.
//

import Foundation

// MARK: - Root Response

struct MatchDetailsResponse: Codable {

    let success: Bool
    let data: MatchDetailsData

    enum CodingKeys: String, CodingKey {
        case success
        case data
    }

    init(from decoder: Decoder) throws {

        let container =
        try decoder.container(
            keyedBy: CodingKeys.self
        )

        success =
        try container.decodeIfPresent(
            Bool.self,
            forKey: .success
        ) ?? false

        data =
        try container.decodeIfPresent(
            MatchDetailsData.self,
            forKey: .data
        ) ?? MatchDetailsData()
    }
}



// MARK: - Data Container

struct MatchDetailsData: Codable {

    let match: MatchDetails
    let stats: [String: String]
    let events: [MatchEvent]

    enum CodingKeys: String, CodingKey {
        case match
        case stats
        case events
    }

    init() {

        match = MatchDetails()
        stats = [:]
        events = []
    }

    init(from decoder: Decoder) throws {

        let container =
        try decoder.container(
            keyedBy: CodingKeys.self
        )

        match =
        try container.decodeIfPresent(
            MatchDetails.self,
            forKey: .match
        ) ?? MatchDetails()

        stats =
        try container.decodeIfPresent(
            [String: String].self,
            forKey: .stats
        ) ?? [:]

        events =
        try container.decodeIfPresent(
            [MatchEvent].self,
            forKey: .events
        ) ?? []
    }
}



// MARK: - Match

struct MatchDetails: Codable {

    let matchId: String
    let homeTeam: Teams
    let awayTeam: Teams

    let homeScore: Int
    let awayScore: Int

    let status: String
    let kickoffUtc: String

    let minute: Int?

    let competitionName: String
    let venue: Venues
    let lineup: Lineup

    enum CodingKeys: String, CodingKey {

        case matchId
        case homeTeam
        case awayTeam

        case homeScore
        case awayScore

        case status
        case kickoffUtc

        case minute
        case competitionName
        case venue
        case lineup
    }

    init() {

        matchId = ""
        homeTeam = Teams()
        awayTeam = Teams()

        homeScore = 0
        awayScore = 0

        status = ""
        kickoffUtc = ""

        minute = nil

        competitionName = ""
        venue = Venues()
        lineup = Lineup()
    }

    init(from decoder: Decoder) throws {

        let container =
        try decoder.container(
            keyedBy: CodingKeys.self
        )

        matchId =
        try container.decodeIfPresent(
            String.self,
            forKey: .matchId
        ) ?? ""

        homeTeam =
        try container.decodeIfPresent(
            Teams.self,
            forKey: .homeTeam
        ) ?? Teams()

        awayTeam =
        try container.decodeIfPresent(
            Teams.self,
            forKey: .awayTeam
        ) ?? Teams()

        homeScore =
        try container.decodeIfPresent(
            Int.self,
            forKey: .homeScore
        ) ?? 0

        awayScore =
        try container.decodeIfPresent(
            Int.self,
            forKey: .awayScore
        ) ?? 0

        status =
        try container.decodeIfPresent(
            String.self,
            forKey: .status
        ) ?? ""

        kickoffUtc =
        try container.decodeIfPresent(
            String.self,
            forKey: .kickoffUtc
        ) ?? ""

        minute =
        try container.decodeIfPresent(
            Int.self,
            forKey: .minute
        )

        competitionName =
        try container.decodeIfPresent(
            String.self,
            forKey: .competitionName
        ) ?? ""

        venue =
        try container.decodeIfPresent(
            Venues.self,
            forKey: .venue
        ) ?? Venues()

        lineup =
        try container.decodeIfPresent(
            Lineup.self,
            forKey: .lineup
        ) ?? Lineup()
    }
}



// MARK: - Team

struct Teams: Codable {

    let id: String
    let name: String
    let shortName: String
    let logoUrl: String
    let primaryColor: String?

    enum CodingKeys: String, CodingKey {

        case id
        case name
        case shortName
        case logoUrl
        case primaryColor
    }

    init() {

        id = ""
        name = ""
        shortName = "TBD"
        logoUrl = ""
        primaryColor = "#333333"
    }

    init(from decoder: Decoder) throws {

        let container =
        try decoder.container(
            keyedBy: CodingKeys.self
        )

        id =
        try container.decodeIfPresent(
            String.self,
            forKey: .id
        ) ?? ""

        name =
        try container.decodeIfPresent(
            String.self,
            forKey: .name
        ) ?? ""

        shortName =
        try container.decodeIfPresent(
            String.self,
            forKey: .shortName
        ) ?? "TBD"

        logoUrl =
        try container.decodeIfPresent(
            String.self,
            forKey: .logoUrl
        ) ?? ""

        primaryColor =
        try container.decodeIfPresent(
            String.self,
            forKey: .primaryColor
        )
    }
}



// MARK: - Venue

struct Venues: Codable {

    let name: String
    let city: String

    enum CodingKeys: String, CodingKey {
        case name
        case city
    }

    init() {

        name = ""
        city = ""
    }

    init(from decoder: Decoder) throws {

        let container =
        try decoder.container(
            keyedBy: CodingKeys.self
        )

        name =
        try container.decodeIfPresent(
            String.self,
            forKey: .name
        ) ?? ""

        city =
        try container.decodeIfPresent(
            String.self,
            forKey: .city
        ) ?? ""
    }
}



// MARK: - Lineup

struct Lineup: Codable {

    let home: [Player]
    let away: [Player]

    enum CodingKeys: String, CodingKey {

        case home
        case away
    }

    init() {

        home = []
        away = []
    }

    init(from decoder: Decoder) throws {

        let container =
        try decoder.container(
            keyedBy: CodingKeys.self
        )

        home =
        try container.decodeIfPresent(
            [Player].self,
            forKey: .home
        ) ?? []

        away =
        try container.decodeIfPresent(
            [Player].self,
            forKey: .away
        ) ?? []
    }
}



// MARK: - Player

struct Player: Codable, Identifiable {

    let id: String
    let name: String
    let position: String
    let number: Int

    var idValue: String { id }

    enum CodingKeys: String, CodingKey {

        case id
        case name
        case position
        case number
    }

    init() {

        id = ""
        name = ""
        position = ""
        number = 0
    }

    init(from decoder: Decoder) throws {

        let container =
        try decoder.container(
            keyedBy: CodingKeys.self
        )

        id =
        try container.decodeIfPresent(
            String.self,
            forKey: .id
        ) ?? ""

        name =
        try container.decodeIfPresent(
            String.self,
            forKey: .name
        ) ?? ""

        position =
        try container.decodeIfPresent(
            String.self,
            forKey: .position
        ) ?? ""

        number =
        try container.decodeIfPresent(
            Int.self,
            forKey: .number
        ) ?? 0
    }
}



// MARK: - Match Event

struct MatchEvent: Codable, Identifiable {

    let eventId: String
    let type: String
    let minute: Int
    let teamId: String
    let playerId: String
    let playerName: String
    let description: String

    var id: String { eventId }

    enum CodingKeys: String, CodingKey {

        case eventId
        case type
        case minute
        case teamId
        case playerId
        case playerName
        case description
    }

    init() {

        eventId = ""
        type = ""
        minute = 0
        teamId = ""
        playerId = ""
        playerName = ""
        description = ""
    }

    init(from decoder: Decoder) throws {

        let container =
        try decoder.container(
            keyedBy: CodingKeys.self
        )

        eventId =
        try container.decodeIfPresent(
            String.self,
            forKey: .eventId
        ) ?? ""

        type =
        try container.decodeIfPresent(
            String.self,
            forKey: .type
        ) ?? ""

        minute =
        try container.decodeIfPresent(
            Int.self,
            forKey: .minute
        ) ?? 0

        teamId =
        try container.decodeIfPresent(
            String.self,
            forKey: .teamId
        ) ?? ""

        playerId =
        try container.decodeIfPresent(
            String.self,
            forKey: .playerId
        ) ?? ""

        playerName =
        try container.decodeIfPresent(
            String.self,
            forKey: .playerName
        ) ?? ""

        description =
        try container.decodeIfPresent(
            String.self,
            forKey: .description
        ) ?? ""
    }
}
