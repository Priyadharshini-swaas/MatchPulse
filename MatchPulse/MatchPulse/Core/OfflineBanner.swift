//
//  OfflineBanner.swift
//  MatchPulse
//

import SwiftUI

// MARK: - Offline Banner (shown at top of screen when offline)
struct OfflineBanner: View {

    let lastUpdated: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.caption)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 1) {
                Text("No Internet Connection")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("Showing cached data from \(lastUpdated)")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            Circle()
                .fill(Color.orange)
                .frame(width: 8, height: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(hex: "B03A2E"))
        .transition(.move(edge: .top).combined(with: .opacity))
        .accessibilityIdentifier("offline_banner")
    }
}

// MARK: - No Cache + No Network View
struct NoCacheOfflineView: View {

    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(hex: "1c1c1e"))
                    .frame(width: 100, height: 100)

                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            HStack(spacing: 6) {
                Image(systemName: "wifi.slash")
                    .font(.caption)
                    .foregroundColor(.orange)
                Text("Connect to internet to load data")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(20)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .accessibilityIdentifier("no_cache_offline_view")
    }
}
