//
//  CompetitionsModel.swift
//  MatchPulse
//
//  Created by Apple on 27/04/26.
//

import Foundation
// MARK: - Model
struct CompetitionResponse: Codable {
    let success: Bool
    let data: CompetitionData

    enum CodingKeys: String, CodingKey {
        case success, data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        data    = try container.decodeIfPresent(CompetitionData.self, forKey: .data) ?? CompetitionData()
    }
}

struct CompetitionData: Codable {
    let competitions: [Competition]

    enum CodingKeys: String, CodingKey {
        case competitions
    }

    init(competitions: [Competition] = []) {
        self.competitions = competitions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        competitions = try container.decodeIfPresent([Competition].self, forKey: .competitions) ?? []
    }
}

struct Competition: Codable, Identifiable {
    let competitionId: String
    let competitionName: String
    let season: String

    var id: String { competitionId }

    enum CodingKeys: String, CodingKey {
        case competitionId, competitionName, season
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        competitionId   = try container.decodeIfPresent(String.self, forKey: .competitionId)   ?? ""
        competitionName = try container.decodeIfPresent(String.self, forKey: .competitionName) ?? ""
        season          = try container.decodeIfPresent(String.self, forKey: .season)          ?? ""
    }
}
