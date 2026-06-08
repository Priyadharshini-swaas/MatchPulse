//
//  ContentAPI.swift
//  MatchPulse
//
//  Created by Apple on 21/04/26.
//

import Foundation

class ContentAPI {

    static let shared = ContentAPI()
    private init() {}

    // MARK: - async/await
    func fetchContent() async throws -> [ContentItem] {

        let urlString = "\(AppStrings.baseURL)/content" 

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(ContentResponse.self, from: data)
        return decoded.data.items
    }
}
