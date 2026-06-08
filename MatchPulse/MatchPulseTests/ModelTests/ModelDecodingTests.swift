//
//  ModelDecodingTests.swift
//  MatchPulseTests
//
//  Tests for JSON decoding of every model in the app.
//  Verifies:
//  - Full JSON decodes correctly
//  - Missing optional fields fall back to defaults (not crashes)
//  - Computed properties work as expected
//

import XCTest
@testable import MatchPulse

final class ModelDecodingTests: XCTestCase {

    // MARK: - Match

    func testMatch_fullJSON_decodesAllFields() {
        let match = TestFixtures.match(
            matchId:   "m-test",
            homeTeam:  "LAFC",
            awayTeam:  "NYCFC",
            homeScore: 2,
            awayScore: 1,
            status:    "LIVE",
            minute:    67
        )
        XCTAssertEqual(match.matchId,         "m-test")
        XCTAssertEqual(match.homeTeam.name,   "LAFC")
        XCTAssertEqual(match.awayTeam.name,   "NYCFC")
        XCTAssertEqual(match.homeScore,       2)
        XCTAssertEqual(match.awayScore,       1)
        XCTAssertEqual(match.status,          "LIVE")
        XCTAssertEqual(match.minute,          67)
        XCTAssertEqual(match.venue.name,      "Banc of California Stadium")
    }

    func testMatch_minimalJSON_usesDefaults() throws {
        let json   = #"{"matchId":"min-test"}"#
        let match  = try JSONDecoder().decode(Match.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(match.matchId,   "min-test")
        XCTAssertEqual(match.homeScore, 0)
        XCTAssertEqual(match.awayScore, 0)
        XCTAssertEqual(match.status,    "")
    }

    func testMatch_idEqualsMatchId() {
        let match = TestFixtures.match(matchId: "id-check")
        XCTAssertEqual(match.id, "id-check")
    }

    // MARK: - Team (inside Match)

    func testTeam_primaryColorIsOptional() {
        let json  = #"{"id":"t1","name":"A","shortName":"A","logoUrl":""}"#
        let team  = try! JSONDecoder().decode(Team.self, from: json.data(using: .utf8)!)
        XCTAssertNil(team.primaryColor)
    }

    func testTeam_conferenceIsOptional() {
        let json = #"{"id":"t1","name":"A","shortName":"A","logoUrl":""}"#
        let team = try! JSONDecoder().decode(Team.self, from: json.data(using: .utf8)!)
        XCTAssertNil(team.conference)
    }

    // MARK: - MatchEvent

    func testMatchEvent_decodesAllFields() {
        let event = TestFixtures.matchEvent(eventId: "e1", type: "YELLOW_CARD", minute: 55)
        XCTAssertEqual(event.eventId,  "e1")
        XCTAssertEqual(event.type,     "YELLOW_CARD")
        XCTAssertEqual(event.minute,   55)
    }

    func testMatchEvent_idEqualsEventId() {
        let event = TestFixtures.matchEvent(eventId: "ev-unique")
        XCTAssertEqual(event.id, "ev-unique")
    }

    func testMatchEvent_minimalJSON_usesDefaults() throws {
        let json  = #"{"eventId":"ev-min"}"#
        let event = try JSONDecoder().decode(MatchEvent.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(event.eventId,    "ev-min")
        XCTAssertEqual(event.minute,     0)
        XCTAssertEqual(event.playerName, "")
    }

    // MARK: - MatchDetailsData

    func testMatchDetailsData_defaultInit_isEmpty() {
        let data = MatchDetailsData()
        XCTAssertEqual(data.match.matchId, "")
        XCTAssertTrue(data.stats.isEmpty)
        XCTAssertTrue(data.events.isEmpty)
    }

    func testMatchDetails_minuteIsOptional() {
        let data = TestFixtures.matchDetailsData()
        XCTAssertNotNil(data.match.minute)
    }

    // MARK: - MatchResponse (root)

    func testMatchResponse_successFlag() throws {
        let json = """
        {"success":true,"data":{"matches":[],"nextCursor":null}}
        """
        let resp = try JSONDecoder().decode(MatchResponse.self, from: json.data(using: .utf8)!)
        XCTAssertTrue(resp.success)
        XCTAssertTrue(resp.data.matches.isEmpty)
    }

    func testMatchResponse_missingFields_usesDefaults() throws {
        let json = #"{}"#
        let resp = try JSONDecoder().decode(MatchResponse.self, from: json.data(using: .utf8)!)
        XCTAssertFalse(resp.success)
        XCTAssertTrue(resp.data.matches.isEmpty)
    }

    // MARK: - TeamPlayer

    func testTeamPlayer_decodesAllFields() {
        let t = TestFixtures.teamPlayer(id: "team#t1", name: "LA FC")
        XCTAssertEqual(t.name,      "LA FC")
        XCTAssertEqual(t.teamId,    "t1")          // "#" stripped
        XCTAssertEqual(t.conference, "Western")
    }

    func testTeamPlayer_idIsFullId() {
        let t = TestFixtures.teamPlayer(id: "team#t1")
        XCTAssertEqual(t.id, "team#t1")
    }

    // MARK: - Players (squad)

    func testPlayers_decodesAllFields() {
        let p = TestFixtures.player(playerId: "p99", name: "Test Player", position: "GK")
        XCTAssertEqual(p.playerId, "p99")
        XCTAssertEqual(p.name,     "Test Player")
        XCTAssertEqual(p.position, "GK")
        XCTAssertEqual(p.id,       "p99")
    }

    func testPlayers_missingName_defaultsToUnknown() throws {
        let json = #"{"playerId":"p0"}"#
        let p = try JSONDecoder().decode(Players.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(p.name, "Unknown Player")
    }

    // MARK: - TeamDetail

    func testTeamDetail_cleanTeamId() {
        let d = TestFixtures.teamDetail(teamId: "team#lafc-123")
        XCTAssertEqual(d.cleanTeamId, "lafc-123")
    }

    func testTeamDetail_noHash_cleanTeamIdIsFull() {
        let d = TestFixtures.teamDetail(teamId: "lafc-123")
        XCTAssertEqual(d.cleanTeamId, "lafc-123")
    }

    func testTeamDetail_seasonStats() {
        let d = TestFixtures.teamDetail()
        XCTAssertEqual(d.season.wins,       10)
        XCTAssertEqual(d.season.form,       "WWDLW")
        XCTAssertEqual(d.season.xG,         28.5, accuracy: 0.001)
    }

    // MARK: - StandingsData

    func testStandingsData_decodesStandings() {
        let data = TestFixtures.standingsData(count: 3)
        XCTAssertEqual(data.standings.count,    3)
        XCTAssertEqual(data.competitionName,    "MLS")
        XCTAssertEqual(data.season,             "2026")
        XCTAssertEqual(data.standings.first?.position, 1)
    }

    func testTeamStanding_idEqualsTeamId() {
        let s = TestFixtures.teamStanding(teamId: "t99")
        XCTAssertEqual(s.id, "t99")
    }

    func testTeamStanding_formIsOptional() throws {
        let json = #"{"position":1,"teamId":"t1","played":10,"wins":6,"draws":2,"losses":2,"goalsFor":15,"goalsAgainst":8,"goalDifference":7,"points":20}"#
        let s = try JSONDecoder().decode(TeamStanding.self, from: json.data(using: .utf8)!)
        XCTAssertNil(s.form)
    }

    // MARK: - Competition

    func testCompetition_decodesAllFields() {
        let c = TestFixtures.competition(id: "mls-2026", name: "MLS", season: "2026")
        XCTAssertEqual(c.competitionId,   "mls-2026")
        XCTAssertEqual(c.competitionName, "MLS")
        XCTAssertEqual(c.season,          "2026")
        XCTAssertEqual(c.id,              "mls-2026")
    }

    // MARK: - ContentItem

    func testContentItem_decodesAllFields() {
        let item = TestFixtures.contentItem(contentId: "c1", headline: "Test Headline", type: "video")
        XCTAssertEqual(item.contentId, "c1")
        XCTAssertEqual(item.headline,  "Test Headline")
        XCTAssertEqual(item.type,      "video")
        XCTAssertEqual(item.id,        "c1")
        XCTAssertFalse(item.tags.isEmpty)
    }

    func testContentItem_missingFields_usesDefaults() throws {
        let json = #"{"contentId":"c-min"}"#
        let item = try JSONDecoder().decode(ContentItem.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(item.contentId, "c-min")
        XCTAssertEqual(item.headline,  "")
        XCTAssertTrue(item.tags.isEmpty)
    }

    // MARK: - Venue

    func testVenue_decodesNameAndCity() {
        let match = TestFixtures.match()
        XCTAssertEqual(match.venue.name, "Banc of California Stadium")
        XCTAssertEqual(match.venue.city, "Los Angeles")
    }

    func testVenue_missingFields_usesDefaults() throws {
        let json = #"{}"#
        let v    = try JSONDecoder().decode(Venue.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(v.name, "")
        XCTAssertEqual(v.city, "")
    }
}
