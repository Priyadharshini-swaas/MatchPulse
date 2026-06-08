//
//  VideoFullScreen.swift
//  MatchPulse
//
//  Created by Apple on 22/04/26.
//  FIX: Renamed from videoFullScreen.swift (PascalCase)
//

import Foundation
import SwiftUI

struct VideoFullScreen: View {

    let item: ContentItem

    var body: some View {
        ScrollView {
            VStack {
                VideoPreviewPlayer(url: item.contentUrl, contentId: item.contentId)
                    .frame(height: 400)
                    .clipped()
                    .cornerRadius(12)   // FIX: was 0.30

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.headline)
                        .foregroundColor(.white)
                        .font(.system(size: 25, weight: .semibold))

                    Text(item.summary)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
            }
            .background(Color.black)
            .cornerRadius(14)
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
}
