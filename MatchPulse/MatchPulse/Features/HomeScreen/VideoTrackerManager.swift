//
//  VideoTrackerManager.swift
//  MatchPulse
//
//  Created by Apple on 28/04/26.
//

import Foundation
import AVKit
import CoreLocation
import UIKit
import Combine
class VideoTrackerManager: NSObject, ObservableObject {

    // MARK: - Properties
    private var timerTask:       Task<Void, Never>? = nil
    private var startTime:       Date?              = nil
    private var player:          AVPlayer?          = nil
    private var contentId:       String             = ""
    private var currentLocation: CLLocation?        = nil

    // MARK: - Reuse shared LocationManager instead of creating a new CLLocationManager
    private let locationManager = CLLocationManager()

    // MARK: - Setup
    func configure(player: AVPlayer, contentId: String) {
        self.player    = player
        self.contentId = contentId
        setupLocation()
    }

    // MARK: - Start Tracking
    func startTracking() {
        // FIX: stop first, then set startTime so it isn't reset
        stopTracking()
        startTime = Date()

        timerTask = Task.detached(priority: .background) { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                guard !Task.isCancelled else { break }
                await self?.postTrackingData()
            }
        }
    }

    // MARK: - Stop Tracking
    func stopTracking() {
        timerTask?.cancel()
        timerTask = nil
    }

    // MARK: - Build & Post Payload
    @MainActor
    private func postTrackingData() async {

        // Only post when video is actually playing
        guard videoStatus() == "playing" else {
            print("⏸ Video not playing — skipping tracker post")
            return
        }

        let payload = VideoTrackingPayload(
            contentId:       contentId,
            deviceName:      deviceName(),
            durationWatched: durationWatched(),
            videoStatus:     videoStatus(),
            timestamp:       currentTimestamp(),
            latitude:        currentLocation?.coordinate.latitude  ?? 0.0,
            longitude:       currentLocation?.coordinate.longitude ?? 0.0
        )

        print("📦 Payload: \(payload)")
        await sendToAPI(payload: payload)
    }

    // MARK: - API Call (fixed: removed hardcoded query param)
    private func sendToAPI(payload: VideoTrackingPayload) async {
        do {
            guard let url = URL(string: "\(AppStrings.baseURL)/content") else { return }

            var request        = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody   = try JSONEncoder().encode(payload)

            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Tracking posted — Status: \(httpResponse.statusCode)")
            }
        } catch {
            print("❌ Tracking error: \(error.localizedDescription)")
        }
    }

    // MARK: - Helpers

    private func deviceName() -> String {
        return UIDevice.current.name
    }

    // Actual playback position from AVPlayer
    @MainActor
    private func durationWatched() -> String {
        guard let player = player else { return "0:00" }

        let currentSeconds = CMTimeGetSeconds(player.currentTime())

        guard !currentSeconds.isNaN,
              !currentSeconds.isInfinite,
              currentSeconds > 0 else { return "0:00" }

        let totalSeconds = Int(currentSeconds)
        let hours        = totalSeconds / 3600
        let min          = (totalSeconds % 3600) / 60
        let sec          = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, min, sec)
        } else {
            return String(format: "%d:%02d", min, sec)
        }
    }

    @MainActor
    private func videoStatus() -> String {
        guard let player = player else { return "unknown" }
        switch player.timeControlStatus {
        case .playing:                      return "playing"
        case .paused:                       return "paused"
        case .waitingToPlayAtSpecifiedRate: return "buffering"
        @unknown default:                   return "unknown"
        }
    }

    private func currentTimestamp() -> String {
        let formatter      = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: Date())
    }
}

// MARK: - CLLocationManagerDelegate
extension VideoTrackerManager: CLLocationManagerDelegate {

    func setupLocation() {
        // FIX: check permission before starting updates
        locationManager.delegate        = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
}
