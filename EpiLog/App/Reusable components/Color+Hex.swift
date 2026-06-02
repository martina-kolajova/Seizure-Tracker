//
//  Color+Hex.swift
//  Seizure Tracker
//

import SwiftUI

extension Color {
    /// Init from a hex string like "#9B59E8" or "9B59E8".
    init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        let r, g, b, a: Double
        switch s.count {
        case 6:
            r = Double((v >> 16) & 0xFF) / 255
            g = Double((v >>  8) & 0xFF) / 255
            b = Double( v        & 0xFF) / 255
            a = 1
        case 8:
            r = Double((v >> 24) & 0xFF) / 255
            g = Double((v >> 16) & 0xFF) / 255
            b = Double((v >>  8) & 0xFF) / 255
            a = Double( v        & 0xFF) / 255
        default:
            r = 1; g = 1; b = 1; a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

/// Shared linear gradient used on the patient-info screens.
struct AppGradient: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "#A855F7"),   // bright purple/violet (top)
                Color(hex: "#3B82F6")    // vivid blue (bottom)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
