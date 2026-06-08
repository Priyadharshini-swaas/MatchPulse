//
//  TeamModel.swift
//  MatchPulse
//
//  Created by Apple on 24/04/26.
//

import Foundation

// MARK: - Root

struct TeamListResponse: Codable {

    let success: Bool
    let data: TeamListData
}

// MARK: - Data

struct TeamListData: Codable {

    let teams: [TeamPlayer]

    enum CodingKeys: String, CodingKey {
        case teams
    }

    init(from decoder: Decoder) throws {

        let container =
        try decoder.container(
            keyedBy: CodingKeys.self
        )

        teams =
        try container.decodeIfPresent(
            [TeamPlayer].self,
            forKey: .teams
        ) ?? []
    }
}

// MARK: - Team Model

struct TeamPlayer: Codable, Identifiable {

    let id: String
    let name: String
    let shortName: String
    let conference: String
    let logoUrl: String
    let primaryColor: String
    var teamId: String {

           return id.components(separatedBy: "#")
               .last ?? id
       }
    enum CodingKeys: String, CodingKey {

        case id
        case name
        case shortName
        case conference
        case logoUrl
        case primaryColor
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
        ) ?? ""

        conference =
        try container.decodeIfPresent(
            String.self,
            forKey: .conference
        ) ?? ""

        logoUrl =
        try container.decodeIfPresent(
            String.self,
            forKey: .logoUrl
        ) ?? ""

        primaryColor =
        try container.decodeIfPresent(
            String.self,
            forKey: .primaryColor
        ) ?? "#000000"
    }
}

// MARK: - Root Response

struct TeamPlayersResponse: Codable {

    let success: Bool
    let data: TeamPlayersData
}

// MARK: - Data Container

struct TeamPlayersData: Codable {

    let teamId: String
    let players: [Players]

    enum CodingKeys: String, CodingKey {
        case teamId
        case players
    }

    init(from decoder: Decoder) throws {

        let container =
        try decoder.container(
            keyedBy: CodingKeys.self
        )

        teamId =
        try container.decodeIfPresent(
            String.self,
            forKey: .teamId
        ) ?? ""

        players =
        try container.decodeIfPresent(
            [Players].self,
            forKey: .players
        ) ?? []
    }
}

// MARK: - Player Model

struct Players: Codable, Identifiable {

    let playerId: String
    let name: String
    let position: String

    var id: String { playerId }

    enum CodingKeys: String, CodingKey {

        case playerId
        case name
        case position
    }

    init(from decoder: Decoder) throws {

        let container =
        try decoder.container(
            keyedBy: CodingKeys.self
        )

        playerId =
        try container.decodeIfPresent(
            String.self,
            forKey: .playerId
        ) ?? ""

        name =
        try container.decodeIfPresent(
            String.self,
            forKey: .name
        ) ?? "Unknown Player"

        position =
        try container.decodeIfPresent(
            String.self,
            forKey: .position
        ) ?? "-"
    }
}
struct TeamDetailResponse: Codable {

    let success: Bool
    let data: TeamDetailData
}

struct TeamDetailData: Codable {

    let team: TeamDetail

    init(
        team: TeamDetail = TeamDetail()
    ) {

        self.team = team
    }

    // MARK: Decoder Init

    init(from decoder: Decoder) throws {

        let container =
        try decoder.container(
            keyedBy: CodingKeys.self
        )

        team =
        try container.decodeIfPresent(
            TeamDetail.self,
            forKey: .team
        ) ?? TeamDetail()
    }
}
struct TeamDetail: Codable {

    let teamId: String
    let name: String
    let shortName: String
    let conference: String
    let logoUrl: String
    let primaryColor: String
    let season: Season
    let competitionIds: [String]

    // MARK: Default Init

    init(
        teamId: String = "",
        name: String = "",
        shortName: String = "",
        conference: String = "",
        logoUrl: String = "",
        primaryColor: String = "#000000",
        season: Season = Season(),
        competitionIds: [String] = []
    ) {

        self.teamId = teamId
        self.name = name
        self.shortName = shortName
        self.conference = conference
        self.logoUrl = logoUrl
        self.primaryColor = primaryColor
        self.season = season
        self.competitionIds = competitionIds
    }

    // MARK: Decoder Init

    init(from decoder: Decoder) throws {

        let container =
        try decoder.container(
            keyedBy: CodingKeys.self
        )

        teamId =
        try container.decodeIfPresent(
            String.self,
            forKey: .teamId
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
        ) ?? ""

        conference =
        try container.decodeIfPresent(
            String.self,
            forKey: .conference
        ) ?? ""

        logoUrl =
        try container.decodeIfPresent(
            String.self,
            forKey: .logoUrl
        ) ?? ""

        primaryColor =
        try container.decodeIfPresent(
            String.self,
            forKey: .primaryColor
        ) ?? "#000000"

        season =
        try container.decodeIfPresent(
            Season.self,
            forKey: .season
        ) ?? Season()

        competitionIds =
        try container.decodeIfPresent(
            [String].self,
            forKey: .competitionIds
        ) ?? []
    }

    // MARK: Clean TeamId

    var cleanTeamId: String {

        teamId
            .components(
                separatedBy: "#"
            )
            .last ?? teamId
    }
}
struct Season: Codable {

    let wins: Int
    let draws: Int
    let losses: Int
    let goalsFor: Int
    let goalsAgainst: Int
    let xG: Double
    let form: String

    // MARK: Default Init

    init(
        wins: Int = 0,
        draws: Int = 0,
        losses: Int = 0,
        goalsFor: Int = 0,
        goalsAgainst: Int = 0,
        xG: Double = 0.0,
        form: String = ""
    ) {

        self.wins = wins
        self.draws = draws
        self.losses = losses
        self.goalsFor = goalsFor
        self.goalsAgainst = goalsAgainst
        self.xG = xG
        self.form = form
    }

    // MARK: Decoder Init

    init(from decoder: Decoder) throws {

        let container =
        try decoder.container(
            keyedBy: CodingKeys.self
        )

        wins =
        try container.decodeIfPresent(
            Int.self,
            forKey: .wins
        ) ?? 0

        draws =
        try container.decodeIfPresent(
            Int.self,
            forKey: .draws
        ) ?? 0

        losses =
        try container.decodeIfPresent(
            Int.self,
            forKey: .losses
        ) ?? 0

        goalsFor =
        try container.decodeIfPresent(
            Int.self,
            forKey: .goalsFor
        ) ?? 0

        goalsAgainst =
        try container.decodeIfPresent(
            Int.self,
            forKey: .goalsAgainst
        ) ?? 0

        xG =
        try container.decodeIfPresent(
            Double.self,
            forKey: .xG
        ) ?? 0.0

        form =
        try container.decodeIfPresent(
            String.self,
            forKey: .form
        ) ?? ""
    }
}
