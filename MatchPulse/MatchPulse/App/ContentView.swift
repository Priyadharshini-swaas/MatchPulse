//
//  ContentView.swift
//  SampleProject
//
//  Created by Apple on 09/04/26.
//

import SwiftUI
import SDWebImageSwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.7
    @State private var opacity = 0.0
    @State private var pulse = false

    var body: some View {
        ZStack {
            Color(.black)

            .ignoresSafeArea()
            .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: pulse)

            if isActive {

                HomeScreen()

            } else {
                VStack(spacing: 20) {

                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 140, height: 140)
                            .scaleEffect(pulse ? 1.2 : 1.0)
                            .blur(radius: 10)
                        AnimatedImage(name: "Logo1.gif")
                            .resizable()
                            .cornerRadius(30)
                                       .frame(width: 150, height: 120)
                                       .scaleEffect(pulse ? 1.2 : 0.8)
                                       .opacity(pulse ? 1 : 0.5)
                                       .animation(.easeInOut(duration: 1).repeatForever(), value: pulse)
                                       .onAppear {
                                           pulse = true
                                       }
                            .font(.system(size: 40))
                            .foregroundColor(Color.black)
                            .accessibilityIdentifier("splash_logo")
                    }

                    Text("MatchPulse")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(opacity)
                        .offset(y: opacity == 1 ? 0 : 20)
                        .accessibilityIdentifier("splash_title")
                }
                .accessibilityIdentifier("splash_screen")
                .onAppear {
                    // Skip 2.5-second delay during UI automation runs
                    if ProcessInfo.processInfo.arguments.contains("UI_TESTING") {
                        isActive = true
                        return
                    }

                    pulse = true

                    // Logo appear animation
                    withAnimation(.easeOut(duration: 1.2)) {
                        scale = 1.0
                        opacity = 1.0
                    }

                    // Navigate to home
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeInOut) {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}


#Preview {
    SplashScreen()
}
