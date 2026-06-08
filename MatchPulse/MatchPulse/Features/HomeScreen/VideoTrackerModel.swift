//
//  VideoTrackerModel.swift
//  MatchPulse
//
//  Created by Apple on 28/04/26.
//

import Foundation

struct VideoTrackingPayload: Codable {

    let contentId:       String
    let deviceName:      String
    let durationWatched: String
    let videoStatus:     String
    let timestamp:       String
    let latitude:        Double
    let longitude:       Double
}
