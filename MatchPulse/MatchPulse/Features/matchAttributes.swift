//
//  matchAttributes.swift
//  SampleProject
//
//  Created by Apple on 18/04/26.
//

import Foundation
import ActivityKit
import WidgetKit
import SwiftUI
struct MatchAttributes: ActivityAttributes {
    
    struct ContentState: Codable, Hashable {
        var homeScore: Int
        var awayScore: Int
        var minute: Int
    }
    
    let homeTeam: String
    let awayTeam: String 
}

class LiveActivityManager {
    
    static var currentActivity: Activity<MatchAttributes>?
    
    static func startMatch() {
        let attributes = MatchAttributes(
            homeTeam: "LAFC",
            awayTeam: "NYCFC"
        )
        
        let initialState = MatchAttributes.ContentState(
            homeScore: 1,
            awayScore: 2,
            minute: 0
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                contentState: initialState,
                pushType: nil
            )
            
            currentActivity = activity
        } catch {
            print("Error starting activity:", error)
        }
    }
}

extension LiveActivityManager {
    
    static func updateScore(home: Int, away: Int, minute: Int) async {
        guard let activity = currentActivity else { return }
        
        let updatedState = MatchAttributes.ContentState(
            homeScore: home,
            awayScore: away,
            minute: minute
        )
        
        await activity.update(using: updatedState)
    }
}
extension LiveActivityManager {
    
    static func endMatch() async {
        guard let activity = currentActivity else { return }
        
        await activity.end(dismissalPolicy: .immediate)
        currentActivity = nil
    }
}


struct MatchLiveActivityWidget: Widget {
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MatchAttributes.self) { context in
            
            // Lock Screen UI
            VStack {
                Text("\(context.attributes.homeTeam) vs \(context.attributes.awayTeam)")
                
                Text("\(context.state.homeScore) - \(context.state.awayScore)")
                    .font(.largeTitle)
                
                Text("\(context.state.minute)'")
            }
            
        } dynamicIsland: { context in
            
            DynamicIsland {
                
                // Expanded view
                DynamicIslandExpandedRegion(.center) {
                    VStack {
                        Text("\(context.attributes.homeTeam) vs \(context.attributes.awayTeam)")
                        Text("\(context.state.homeScore) - \(context.state.awayScore)")
                        Text("\(context.state.minute)'")
                    }
                }
                
            } compactLeading: {
                Text("\(context.state.homeScore)")
            } compactTrailing: {
                Text("\(context.state.awayScore)")
            } minimal: {
                Text("\(context.state.homeScore)-\(context.state.awayScore)")
            }
        }
    }
}
