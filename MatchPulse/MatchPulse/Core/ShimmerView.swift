//
//  ShimmerView.swift
//  MatchPulse
//

import SwiftUI

// MARK: - Shimmer Modifier (reusable on any view)
struct ShimmerEffect: ViewModifier {

    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.12),
                            Color.white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                    .animation(
                        Animation.linear(duration: 1.3).repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                }
                .clipped()
            )
            .onAppear { isAnimating = true }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Shimmer Box (reusable placeholder block)
struct ShimmerBox: View {
    var width: CGFloat? = nil
    var height: CGFloat = 14
    var cornerRadius: CGFloat = 6

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color(hex: "2c2c2e"))
            .frame(width: width, height: height)
            .shimmer()
    }
}

// MARK: - Home Screen Shimmer
struct HomeShimmerView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                // Live matches shimmer
                VStack(alignment: .leading, spacing: 10) {
                    ShimmerBox(width: 120, height: 16)
                        .padding(.horizontal)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<3, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "2c2c2e"))
                                    .frame(width: 250, height: 110)
                                    .shimmer()
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Content cards shimmer
                ForEach(0..<4, id: \.self) { _ in
                    ContentCardShimmer()
                }
            }
            .padding()
        }
        .background(Color.black)
    }
}

struct ContentCardShimmer: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "2c2c2e"))
                .frame(height: 250)
                .shimmer()

            ShimmerBox(height: 16).padding(.horizontal, 4)
            ShimmerBox(width: 200, height: 12).padding(.horizontal, 4)
        }
        .padding(.bottom, 4)
    }
}

// MARK: - Match List Shimmer
struct MatchListShimmerView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(0..<6, id: \.self) { _ in
                    MatchCardShimmer()
                        .padding(.horizontal)
                }
            }
        }
        .background(Color.black)
    }
}

struct MatchCardShimmer: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ShimmerBox(width: 60, height: 20, cornerRadius: 6)
                Spacer()
            }

            HStack {
                // Home team
                VStack(spacing: 6) {
                    Circle().fill(Color(hex: "2c2c2e")).frame(width: 50, height: 50).shimmer()
                    ShimmerBox(width: 50, height: 12)
                }
                Spacer()
                ShimmerBox(width: 80, height: 28, cornerRadius: 8)
                Spacer()
                // Away team
                VStack(spacing: 6) {
                    Circle().fill(Color(hex: "2c2c2e")).frame(width: 50, height: 50).shimmer()
                    ShimmerBox(width: 50, height: 12)
                }
            }

            Divider().background(Color.white.opacity(0.1))

            HStack {
                ShimmerBox(width: 100, height: 12)
                Spacer()
                ShimmerBox(width: 80, height: 12)
            }
        }
        .padding()
        .background(Color(hex: "1c1c1e"))
        .cornerRadius(16)
    }
}

// MARK: - Competition Grid Shimmer
struct CompetitionShimmerGrid: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                ShimmerBox(width: 160, height: 18)
                ShimmerBox(width: 120, height: 12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 8)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(0..<6, id: \.self) { _ in
                    CompetitionCardShimmer()
                }
            }
            .padding()
        }
        .background(Color.black)
    }
}

struct CompetitionCardShimmer: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color(hex: "2c2c2e")
                .frame(height: 80)
                .shimmer()

            VStack(alignment: .leading, spacing: 10) {
                ShimmerBox(height: 14).padding(.trailing, 20)
                ShimmerBox(width: 80, height: 10)
                ShimmerBox(height: 2)
            }
            .padding(12)
            .background(Color(hex: "1c1c1e"))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
    }
}

// MARK: - Team Slider Shimmer
struct TeamSliderShimmerView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "1c1c1e"))
                .padding(.horizontal)
                .shimmer()

            VStack(spacing: 20) {
                Circle()
                    .fill(Color(hex: "2c2c2e"))
                    .frame(width: 200, height: 200)
                    .shimmer()

                ShimmerBox(width: 160, height: 20)
                ShimmerBox(width: 100, height: 14)

                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "2c2c2e"))
                    .frame(height: 50)
                    .padding(.horizontal, 60)
                    .shimmer()
            }
        }
        .frame(height: 850)
    }
}

// MARK: - Team Members Shimmer
struct TeamMembersShimmerView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // Header shimmer
                VStack(spacing: 12) {
                    Circle().fill(Color(hex: "2c2c2e")).frame(width: 80, height: 80).shimmer()
                    ShimmerBox(width: 140, height: 18)
                    ShimmerBox(width: 100, height: 14)
                    ShimmerBox(width: 90, height: 36, cornerRadius: 18)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "1c1c1e"))
                .cornerRadius(20)
                .padding(.horizontal)

                // Stats shimmer
                VStack(spacing: 14) {
                    ShimmerBox(width: 120, height: 16)
                    HStack {
                        ForEach(0..<5, id: \.self) { _ in
                            VStack(spacing: 6) {
                                ShimmerBox(width: 30, height: 12)
                                ShimmerBox(width: 30, height: 18)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding()
                .background(Color(hex: "1c1c1e"))
                .cornerRadius(16)
                .padding(.horizontal)

                // Players shimmer
                LazyVStack(spacing: 12) {
                    ForEach(0..<8, id: \.self) { _ in
                        PlayerCardShimmer()
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .background(Color.black)
    }
}

struct PlayerCardShimmer: View {
    var body: some View {
        HStack(spacing: 16) {
            Circle().fill(Color(hex: "2c2c2e")).frame(width: 44, height: 44).shimmer()
            VStack(alignment: .leading, spacing: 6) {
                ShimmerBox(width: 140, height: 14)
                ShimmerBox(width: 80, height: 11)
            }
            Spacer()
            ShimmerBox(width: 36, height: 24, cornerRadius: 6)
        }
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(14)
    }
}

// MARK: - Match Details Shimmer
struct MatchDetailsShimmerView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {

                // Header shimmer
                VStack(spacing: 16) {
                    HStack {
                        VStack(spacing: 8) {
                            Circle().fill(Color(hex: "2c2c2e")).frame(width: 60, height: 60).shimmer()
                            ShimmerBox(width: 60, height: 14)
                        }
                        Spacer()
                        ShimmerBox(width: 100, height: 34, cornerRadius: 8)
                        Spacer()
                        VStack(spacing: 8) {
                            Circle().fill(Color(hex: "2c2c2e")).frame(width: 60, height: 60).shimmer()
                            ShimmerBox(width: 60, height: 14)
                        }
                    }
                    ShimmerBox(width: 120, height: 12)
                }
                .padding()
                .background(Color(hex: "1c1c1e"))
                .cornerRadius(18)
                .padding()

                // Events shimmer
                VStack(alignment: .leading, spacing: 12) {
                    ShimmerBox(width: 140, height: 16)
                    ForEach(0..<5, id: \.self) { _ in
                        HStack(spacing: 12) {
                            ShimmerBox(width: 36, height: 14)
                            Circle().fill(Color(hex: "2c2c2e")).frame(width: 20, height: 20).shimmer()
                            VStack(alignment: .leading, spacing: 5) {
                                ShimmerBox(width: 120, height: 14)
                                ShimmerBox(width: 80, height: 11)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.black)
    }
}
