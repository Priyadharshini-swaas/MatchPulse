//
//  color.swift
//  MatchPulse
//
//  Created by Apple on 21/04/26.
//

import Foundation
import SwiftUI

extension Color {

    // MARK: - Existing (6 digit hex, no alpha)
    init(hex: String) {

        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64

        r = (int >> 16) & 0xFF
        g = (int >> 8) & 0xFF
        b = int & 0xFF

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }

    // MARK: - New (hex + custom opacity)
    init(hex: String, opacity: Double) {

        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64

        r = (int >> 16) & 0xFF
        g = (int >> 8) & 0xFF
        b = int & 0xFF

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: opacity
        )
    }
}
