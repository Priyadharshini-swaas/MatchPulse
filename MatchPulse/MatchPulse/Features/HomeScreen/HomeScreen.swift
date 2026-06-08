//
//  HomeScreen.swift
//  MatchPulse
//

import Foundation
import SwiftUI
import AVKit
import AVFoundation
import FirebasePerformance
import FirebaseCrashlytics

// MARK: - Home Content View
struct HomeContentView: View {

    @StateObject var viewModel = ContentViewModel()
    @StateObject var viewMatch = MatchViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading || viewMatch.isLoading {
                HomeShimmerView()

            } else if !viewModel.isOffline && viewModel.items.isEmpty && viewModel.errorMessage != nil {
                ErrorView(message: viewModel.errorMessage ?? "Something went wrong") {
                    loadDashboard()
                }

            } else if viewModel.isOffline && viewModel.items.isEmpty {
                // Offline AND no cache at all
                NoCacheOfflineView(
                    icon: "house.fill",
                    title: "No Content Available",
                    message: "Open the app with internet once to cache content for offline use"
                )

            } else {
                VStack(spacing: 0) {
                    // Offline banner
                    if viewModel.isOffline {
                        OfflineBanner(lastUpdated: viewModel.lastUpdated)
                    }

                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            LiveMatchesSection(match: viewMatch.matches)
//                            ForEach(viewModel.items) { item in
                                ContentCardView()
//                                    .accessibilityIdentifier("content_card_\(item.contentId)")
//                            }
                        }
                        .accessibilityIdentifier("home_content_list")
                        .padding()
                    }
                    .refreshable { loadDashboard() }
                }
            }
        }
        .background(Color.black)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Home")
                    .foregroundStyle(Color.white)
                    .font(.system(size: 20, weight: .semibold))
                    .accessibilityIdentifier("nav_title_home")
            }
        }
        .toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsManager.logScreen("Home")
            loadDashboard()
        }
    }

    func scheduleNotification() {

        let content = UNMutableNotificationContent()
        content.title = "Match Starting Now!"
        content.body = "The match has started. Don't miss a moment of the action."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Notification Scheduled")
            }
        }
    }
    private func loadDashboard() {
        Task {
            let trace = AnalyticsManager.startTrace("dashboard_load")
            async let matchLoad: Void  = viewMatch.loadMatches()
            async let contentLoad: Void = viewModel.loadContent()
            await matchLoad
            await contentLoad
            trace?.stop()
//            let error = NSError(
//                domain: "com.matchpulse.test",
//                code: 1001,
//                userInfo: [NSLocalizedDescriptionKey: "Test non-fatal error"]
//            )
//
//            Crashlytics.crashlytics().record(error: error)
//            Crashlytics.crashlytics().log("Crash from Homeview")
//            fatalError("Test Crash")
            scheduleNotification()
        }
    }
}

// MARK: - Content Card
struct ContentCardView: View {

//    let item: ContentItem
    @State private var player = AVPlayer(
           url: URL(
               string: "https://stream-akamai.castr.com/5b9352dbda7b8c769937e459/live_2361c920455111ea85db6911fe397b9e/index.fmp4.m3u8"
           )!
       )
    var body: some View {
//        NavigationLink(destination: VideoFullScreen(item: item)) {
            VStack(alignment: .leading, spacing: 10) {
//                VideoPreviewPlayer(url: "https://stream-akamai.castr.com/5b9352dbda7b8c769937e459/live_2361c920455111ea85db6911fe397b9e/index.fmp4.m3u8", contentId: "1")
                    PiPVideoPlayer(player: player)
                    .frame(height: 250)
                    .clipped()
                    .cornerRadius(12)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Live Video Streaming")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal)
//                VStack(alignment: .leading, spacing: 6) {
//                    Text(item.headline)
//                        .font(.headline)
//                        .foregroundColor(.white)
//                    Text(item.summary)
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
//                .padding(.horizontal)
            }
            .background(Color.black)
            .cornerRadius(14)
//        }
    }
}

// MARK: - Live Match Card
struct LiveMatchCardView: View {

    let match: Match

    var gradientBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: match.homeTeam.primaryColor ?? "#1E1E1E").opacity(0.5),
                Color(hex: match.awayTeam.primaryColor ?? "#444444").opacity(0.5)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(match.venue.name).font(.caption).foregroundColor(.white.opacity(0.9))
                Spacer()
                Text(match.venue.city).font(.caption).foregroundColor(.white.opacity(0.9))
            }
            HStack {
                TeamView(team: match.homeTeam)
                Spacer()
                Text("\(match.homeScore)").foregroundColor(.white)
                Text("-").foregroundColor(.white)
                Text("\(match.awayScore)").foregroundColor(.white)
                Spacer()
                TeamView(team: match.awayTeam)
            }
            Text(match.status).font(.caption2).foregroundColor(.red)
        }
        .padding()
        .frame(width: 250)
        .background(gradientBackground)
        .cornerRadius(12)
    }
}

// MARK: - Live Matches Section
struct LiveMatchesSection: View {

    let match: [Match]

    var body: some View {
        VStack(alignment: .leading) {
            if !match.isEmpty {
                Text("LIVE MATCHES")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.horizontal)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(match) { match in
                        LiveMatchCardView(match: match)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Video Preview Player
struct VideoPreviewPlayer: View {

    let url: String
    let contentId: String

    @State private var player: AVPlayer?   = nil
    @State private var isPlayerReady       = false
    @State private var showFullScreen      = false
    @StateObject private var tracker       = VideoTrackerManager()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if isPlayerReady, let player = player {
                VideoPlayer(player: player)
                    .transition(.opacity.animation(.easeIn(duration: 0.3)))
                    .onTapGesture {}
            } else {
                ZStack {
                    Color(hex: "1c1c1e")
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.3)
                        Text("Preparing video...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if isPlayerReady {
                Button(action: { showFullScreen = true }) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                        .padding()
                }
            }
        }
        .onAppear { preparePlayer() }
        .onDisappear {
            player?.pause()
            player        = nil
            isPlayerReady = false
            tracker.stopTracking()
        }
        .fullScreenCover(isPresented: $showFullScreen, onDismiss: {
            player?.isMuted = true
            player?.play()
            tracker.startTracking()
        }) {
            LandscapeVideoPlayer(player: player)
                .ignoresSafeArea()
                .onAppear { tracker.stopTracking() }
        }
    }

    private func preparePlayer() {
        guard let videoURL = URL(string: url) else { return }
        Task.detached(priority: .userInitiated) {
            let asset = AVURLAsset(url: videoURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: false])
            await asset.loadValues(forKeys: ["playable", "tracks"])
            let item      = AVPlayerItem(asset: asset)
            let newPlayer = AVPlayer(playerItem: item)
            newPlayer.isMuted = true
            newPlayer.automaticallyWaitsToMinimizeStalling = true
            await MainActor.run {
                player = newPlayer
                player?.play()
                tracker.configure(player: newPlayer, contentId: contentId)
                tracker.startTracking()
                withAnimation { isPlayerReady = true }
            }
        }
    }
}

// MARK: - Landscape Full Screen Player
struct LandscapeVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer?
    func makeUIViewController(context: Context) -> LandscapePlayerViewController {
        let vc = LandscapePlayerViewController()
        vc.player = player
        return vc
    }
    func updateUIViewController(_ uiViewController: LandscapePlayerViewController, context: Context) {}
}

class LandscapePlayerViewController: UIViewController {
    var player: AVPlayer?
    private var playerViewController: AVPlayerViewController?
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .landscapeRight }
    override var shouldAutorotate: Bool { true }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupPlayer()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 16.0, *) {
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 16.0, *) { self.setNeedsUpdateOfSupportedInterfaceOrientations() }
    }
    private func setupPlayer() {
        let playerVC = AVPlayerViewController()
        playerVC.player                = player
        playerVC.showsPlaybackControls = true
        playerVC.videoGravity          = .resizeAspectFill
        addChild(playerVC)
        view.addSubview(playerVC.view)
        playerVC.view.frame            = view.bounds
        playerVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerVC.didMove(toParent: self)
        player?.isMuted = false
        player?.play()
        self.playerViewController = playerVC
    }
}

class PlayerUIView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}

// MARK: - Shared TeamView
struct TeamView: View {
    let team: Team
    var body: some View {
        VStack {
            if !team.logoUrl.isEmpty, let url = URL(string: team.logoUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit().frame(width: 50, height: 50)
                } placeholder: {
                    Circle().fill(Color(hex: "2c2c2e")).frame(width: 50, height: 50).shimmer()
                }
            } else {
                Image(systemName: "sportscourt")
                    .resizable().scaledToFit().frame(width: 30, height: 30).foregroundColor(.gray)
            }
            Text(team.shortName).font(.headline).foregroundColor(.white)
        }
        .frame(width: 50)
    }
}



struct PiPVideoPlayer: UIViewControllerRepresentable {

    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {

        let controller = AVPlayerViewController()

        controller.player = player

        controller.allowsPictureInPicturePlayback = true

        controller.canStartPictureInPictureAutomaticallyFromInline = true

        controller.delegate = context.coordinator

        controller.showsPlaybackControls = true

        return controller
    }

    func updateUIViewController(
        _ uiViewController: AVPlayerViewController,
        context: Context
    ) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, AVPlayerViewControllerDelegate {

        func playerViewControllerWillStartPictureInPicture(
            _ playerViewController: AVPlayerViewController
        ) {
            print("PiP Started")
        }

        func playerViewControllerDidStartPictureInPicture(
            _ playerViewController: AVPlayerViewController
        ) {
            print("PiP Running")
        }

        func playerViewControllerWillStopPictureInPicture(
            _ playerViewController: AVPlayerViewController
        ) {
            print("PiP Stopping")
        }

        func playerViewControllerDidStopPictureInPicture(
            _ playerViewController: AVPlayerViewController
        ) {
            print("PiP Stopped")
        }
    }
}
