//
//  contentModel.swift
//  MatchPulse
//
//  Created by Apple on 21/04/26.
//

import Foundation

// MARK: Root

struct ContentResponse: Codable {

    let success: Bool
    let data: ContentData
}

// MARK: Data

struct ContentData: Codable {

    let items: [ContentItem]

    enum CodingKeys: String, CodingKey {
        case items
    }

    init(from decoder: Decoder) throws {

        let container =
        try decoder.container(
            keyedBy: CodingKeys.self
        )

        items =
        try container.decodeIfPresent(
            [ContentItem].self,
            forKey: .items
        ) ?? []
    }
}

// MARK: Content Item

struct ContentItem: Codable, Identifiable {

    let contentId: String
    let type: String
    let headline: String
    let summary: String
    let publishedAt: String
    let thumbnailUrl: String
    let contentUrl: String
    let tags: [String]

    var id: String { contentId }

    enum CodingKeys: String, CodingKey {

        case contentId
        case type
        case headline
        case summary
        case publishedAt
        case thumbnailUrl
        case contentUrl
        case tags
    }

    init(from decoder: Decoder) throws {

        let container =
        try decoder.container(
            keyedBy: CodingKeys.self
        )

        contentId =
        try container.decodeIfPresent(
            String.self,
            forKey: .contentId
        ) ?? ""

        type =
        try container.decodeIfPresent(
            String.self,
            forKey: .type
        ) ?? ""

        headline =
        try container.decodeIfPresent(
            String.self,
            forKey: .headline
        ) ?? ""

        summary =
        try container.decodeIfPresent(
            String.self,
            forKey: .summary
        ) ?? ""

        publishedAt =
        try container.decodeIfPresent(
            String.self,
            forKey: .publishedAt
        ) ?? ""

        thumbnailUrl =
        try container.decodeIfPresent(
            String.self,
            forKey: .thumbnailUrl
        ) ?? ""

        contentUrl =
        try container.decodeIfPresent(
            String.self,
            forKey: .contentUrl
        ) ?? ""

        tags =
        try container.decodeIfPresent(
            [String].self,
            forKey: .tags
        ) ?? []
    }
}
