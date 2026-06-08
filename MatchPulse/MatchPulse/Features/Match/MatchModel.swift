//
//  MatchModel.swift
//  SampleProject
//
//  Created by Apple on 21/04/26.
//

import Foundation

// MARK: - Root Response
struct MatchResponse: Codable {

    let success: Bool
    let data: MatchData

    enum CodingKeys: String, CodingKey {
        case success
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        data = try container.decodeIfPresent(MatchData.self, forKey: .data) ?? MatchData()
    }
}

// MARK: - Data Container
struct MatchData: Codable {

    let matches: [Match]
    let nextCursor: String?

    enum CodingKeys: String, CodingKey {
        case matches
        case nextCursor
    }

    init(matches: [Match] = [], nextCursor: String? = nil) {
        self.matches = matches
        self.nextCursor = nextCursor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        matches = try container.decodeIfPresent([Match].self, forKey: .matches) ?? []
        nextCursor = try container.decodeIfPresent(String.self, forKey: .nextCursor)
    }
}

// MARK: - Match
struct Match: Codable, Identifiable {

    let matchId: String
    let homeTeam: Team
    let awayTeam: Team
    let homeScore: Int
    let awayScore: Int
    let status: String
    let kickoffUtc: String
    let minute: Int
    let competitionId: String
    let venue: Venue

    var id: String { matchId }

    enum CodingKeys: String, CodingKey {
        case matchId
        case homeTeam
        case awayTeam
        case homeScore
        case awayScore
        case status
        case kickoffUtc
        case minute
        case competitionId
        case venue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        matchId       = try container.decodeIfPresent(String.self, forKey: .matchId)       ?? ""
        homeTeam      = try container.decodeIfPresent(Team.self,   forKey: .homeTeam)      ?? Team()
        awayTeam      = try container.decodeIfPresent(Team.self,   forKey: .awayTeam)      ?? Team()
        homeScore     = try container.decodeIfPresent(Int.self,    forKey: .homeScore)     ?? 0
        awayScore     = try container.decodeIfPresent(Int.self,    forKey: .awayScore)     ?? 0
        status        = try container.decodeIfPresent(String.self, forKey: .status)        ?? ""
        kickoffUtc    = try container.decodeIfPresent(String.self, forKey: .kickoffUtc)    ?? ""
        minute        = try container.decodeIfPresent(Int.self,    forKey: .minute)        ?? 0
        competitionId = try container.decodeIfPresent(String.self, forKey: .competitionId) ?? ""
        venue         = try container.decodeIfPresent(Venue.self,  forKey: .venue)         ?? Venue()
    }
}

// MARK: - Team
struct Team: Codable {

    let id: String
    let name: String
    let shortName: String
    let conference: String?
    let logoUrl: String
    let primaryColor: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case shortName
        case conference
        case logoUrl
        case primaryColor
    }

    init(
        id: String = "",
        name: String = "",
        shortName: String = "",
        conference: String? = nil,
        logoUrl: String = "",
        primaryColor: String? = nil
    ) {
        self.id = id
        self.name = name
        self.shortName = shortName
        self.conference = conference
        self.logoUrl = logoUrl
        self.primaryColor = primaryColor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id           = try container.decodeIfPresent(String.self, forKey: .id)           ?? ""
        name         = try container.decodeIfPresent(String.self, forKey: .name)         ?? ""
        shortName    = try container.decodeIfPresent(String.self, forKey: .shortName)    ?? ""
        conference   = try container.decodeIfPresent(String.self, forKey: .conference)
        logoUrl      = try container.decodeIfPresent(String.self, forKey: .logoUrl)      ?? ""
        primaryColor = try container.decodeIfPresent(String.self, forKey: .primaryColor)
    }
}

// MARK: - Venue
struct Venue: Codable {

    let name: String
    let city: String

    enum CodingKeys: String, CodingKey {
        case name
        case city
    }

    init(name: String = "", city: String = "") {
        self.name = name
        self.city = city
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        city = try container.decodeIfPresent(String.self, forKey: .city) ?? ""
    }
}

// MARK: - Match Events Response
struct MatchEventsResponse: Codable {

    let success: Bool
    let data: MatchEventsData

    enum CodingKeys: String, CodingKey {
        case success
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decodeIfPresent(Bool.self,           forKey: .success) ?? false
        data    = try container.decodeIfPresent(MatchEventsData.self, forKey: .data)   ?? MatchEventsData()
    }
}

// MARK: - Match Events Data
struct MatchEventsData: Codable {

    let events: [MatchEvent]

    enum CodingKeys: String, CodingKey {
        case events
    }

    init(events: [MatchEvent] = []) {
        self.events = events
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        events = try container.decodeIfPresent([MatchEvent].self, forKey: .events) ?? []
    }
}
