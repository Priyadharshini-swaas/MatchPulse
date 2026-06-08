//
//  AnalyticsManager.swift
//  MatchPulse
//

import Foundation
import FirebaseAnalytics
import FirebasePerformance
import FirebaseCrashlytics

/// Central hub for all Firebase Analytics events and Performance traces.
struct AnalyticsManager {

    // MARK: - Screen View

    static func logScreen(_ screenName: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName
        ])
        Crashlytics.crashlytics().log("Screen: \(screenName)")
    }

    // MARK: - Performance Trace

    /// Starts a named Performance trace. Call `.stop()` on the returned trace when the work is done.
    static func startTrace(_ name: String) -> Trace? {
        let trace = Performance.startTrace(name: name)
        return trace
    }

    // MARK: - API Success / Failure

    static func logAPISuccess(endpoint: String, itemCount: Int) {
        Analytics.logEvent("api_success", parameters: [
            "endpoint": endpoint,
            "item_count": itemCount
        ])
    }

    static func logAPIFailure(endpoint: String, error: String) {
        Analytics.logEvent("api_failure", parameters: [
            "endpoint": endpoint,
            "error": error
        ])
        Crashlytics.crashlytics().log("API failure [\(endpoint)]: \(error)")
    }

    // MARK: - Cache

    static func logCacheHit(key: String) {
        Analytics.logEvent("cache_hit", parameters: ["cache_key": key])
    }

    static func logCacheFallback(key: String, reason: String) {
        Analytics.logEvent("cache_fallback", parameters: [
            "cache_key": key,
            "reason": reason
        ])
    }

    // MARK: - User Actions

    static func logMatchTapped(matchId: String, matchName: String) {
        Analytics.logEvent("match_tapped", parameters: [
            "match_id": matchId,
            "match_name": matchName
        ])
    }

    static func logCompetitionSelected(competitionId: String, name: String) {
        Analytics.logEvent("competition_selected", parameters: [
            "competition_id": competitionId,
            "competition_name": name
        ])
    }

    static func logTeamSelected(teamId: String, teamName: String) {
        Analytics.logEvent("team_selected", parameters: [
            "team_id": teamId,
            "team_name": teamName
        ])
    }

    static func logStandingsViewed(competitionId: String) {
        Analytics.logEvent("standings_viewed", parameters: [
            "competition_id": competitionId
        ])
    }

    static func logMatchDetailsViewed(matchId: String) {
        Analytics.logEvent("match_details_viewed", parameters: [
            "match_id": matchId
        ])
    }

    static func logVideoPlayed(videoId: String) {
        Analytics.logEvent("video_played", parameters: [
            "video_id": videoId
        ])
    }

    static func logNotificationReceived(title: String) {
        Analytics.logEvent("notification_received", parameters: [
            "title": title
        ])
    }

    static func logNotificationTapped(title: String) {
        Analytics.logEvent("notification_tapped", parameters: [
            "title": title
        ])
    }
}
