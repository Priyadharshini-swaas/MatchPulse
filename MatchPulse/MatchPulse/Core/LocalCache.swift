//
//  LocalCache.swift
//  MatchPulse
//

import Foundation

// MARK: - Local Cache Manager
// Stores data in UserDefaults as JSON
// Key-value: cacheKey -> encoded JSON Data

class LocalCache {

    static let shared = LocalCache()

    private let defaults: UserDefaults

    /// Production: use `.shared` (UserDefaults.standard).
    /// Tests: pass a private named suite so each test is fully isolated.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Save
    func save<T: Encodable>(_ value: T, key: CacheKey) {
        do {
            let data = try JSONEncoder().encode(value)
            defaults.set(data, forKey: key.rawValue)
            // Save timestamp so we know when cache was last updated
            defaults.set(Date(), forKey: key.timestampKey)
            print("✅ Cache saved: \(key.rawValue)")
        } catch {
            print("❌ Cache save failed [\(key.rawValue)]: \(error)")
        }
    }

    // MARK: - Load
    func load<T: Decodable>(_ type: T.Type, key: CacheKey) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else {
            print("📭 No cache found: \(key.rawValue)")
            return nil
        }
        do {
            let value = try JSONDecoder().decode(T.self, from: data)
            print("📦 Cache loaded: \(key.rawValue)")
            return value
        } catch {
            print("❌ Cache load failed [\(key.rawValue)]: \(error)")
            return nil
        }
    }

    // MARK: - Clear
    func clear(key: CacheKey) {
        defaults.removeObject(forKey: key.rawValue)
        defaults.removeObject(forKey: key.timestampKey)
    }

    func clearAll() {
        CacheKey.allCases.forEach { clear(key: $0) }
    }

    // MARK: - Cache Age
    func cacheAge(for key: CacheKey) -> TimeInterval? {
        guard let savedDate = defaults.object(forKey: key.timestampKey) as? Date else {
            return nil
        }
        return Date().timeIntervalSince(savedDate)
    }

    func isCacheStale(key: CacheKey, maxAge: TimeInterval = 300) -> Bool {
        guard let age = cacheAge(for: key) else { return true }
        return age > maxAge  // Default: stale after 5 minutes
    }

    func lastUpdatedText(for key: CacheKey) -> String {
        guard let date = defaults.object(forKey: key.timestampKey) as? Date else {
            return "Never"
        }
        let formatter        = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Cache Keys
enum CacheKey: String, CaseIterable {
    case matches      = "cache_matches"
    case content      = "cache_content"
    case competitions = "cache_competitions"
    case teams        = "cache_teams"
    case standings    = "cache_standings"
    
    var timestampKey: String { rawValue + "_timestamp" }
}
