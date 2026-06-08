//
//  StandingModel.swift
//  MatchPulse
//
//  Created by Apple on 05/05/26.
//

import Foundation

struct StandingsResponse: Codable {

    let success: Bool
    let data: StandingsData

    enum CodingKeys: String, CodingKey {
        case success, data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decodeIfPresent(Bool.self,          forKey: .success) ?? false
        data    = try container.decodeIfPresent(StandingsData.self, forKey: .data)    ?? StandingsData()
    }
}

struct StandingsData: Codable {

    let competitionId:   String
    let competitionName: String
    let season:          String
    let standings:       [TeamStanding]

    enum CodingKeys: String, CodingKey {
        case competitionId, competitionName, season, standings
    }

    init(
        competitionId:   String        = "",
        competitionName: String        = "",
        season:          String        = "",
        standings:       [TeamStanding] = []
    ) {
        self.competitionId   = competitionId
        self.competitionName = competitionName
        self.season          = season
        self.standings       = standings
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        competitionId   = try container.decodeIfPresent(String.self,         forKey: .competitionId)   ?? ""
        competitionName = try container.decodeIfPresent(String.self,         forKey: .competitionName) ?? ""
        season          = try container.decodeIfPresent(String.self,         forKey: .season)          ?? ""
        standings       = try container.decodeIfPresent([TeamStanding].self, forKey: .standings)       ?? []
    }
}

struct TeamStanding: Codable, Identifiable {

    var id: String { teamId }

    let position:       Int
    let teamId:         String
    let teamName:       String?
    let shortName:      String?
    let logoUrl:        String?
    let played:         Int
    let wins:           Int
    let draws:          Int
    let losses:         Int
    let goalsFor:       Int
    let goalsAgainst:   Int
    let goalDifference: Int
    let points:         Int
    let form:           String?

    enum CodingKeys: String, CodingKey {
        case position, teamId, teamName, shortName, logoUrl
        case played, wins, draws, losses
        case goalsFor, goalsAgainst, goalDifference, points, form
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        position       = try container.decodeIfPresent(Int.self,    forKey: .position)       ?? 0
        teamId         = try container.decodeIfPresent(String.self, forKey: .teamId)         ?? ""
        teamName       = try container.decodeIfPresent(String.self, forKey: .teamName)
        shortName      = try container.decodeIfPresent(String.self, forKey: .shortName)
        logoUrl        = try container.decodeIfPresent(String.self, forKey: .logoUrl)
        played         = try container.decodeIfPresent(Int.self,    forKey: .played)         ?? 0
        wins           = try container.decodeIfPresent(Int.self,    forKey: .wins)           ?? 0
        draws          = try container.decodeIfPresent(Int.self,    forKey: .draws)          ?? 0
        losses         = try container.decodeIfPresent(Int.self,    forKey: .losses)         ?? 0
        goalsFor       = try container.decodeIfPresent(Int.self,    forKey: .goalsFor)       ?? 0
        goalsAgainst   = try container.decodeIfPresent(Int.self,    forKey: .goalsAgainst)   ?? 0
        goalDifference = try container.decodeIfPresent(Int.self,    forKey: .goalDifference) ?? 0
        points         = try container.decodeIfPresent(Int.self,    forKey: .points)         ?? 0
        form           = try container.decodeIfPresent(String.self, forKey: .form)
    }
}
