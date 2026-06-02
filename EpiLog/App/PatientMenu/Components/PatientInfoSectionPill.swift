//
//  PatientInfoSectionPill.swift
//  EpiLog
//
//  Created by Martina Kolajová on 11.01.2026.
//
import SwiftUI

struct PatientInfoSectionPill: View {
    let section: InfoSection

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: section.iconName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
            Text(section.rawValue)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        // Tight dark halo on just the glyphs keeps white text legible over
        // any bright hotspots in the glass, without dimming the glass itself.
        .shadow(color: .black.opacity(0.45), radius: 3, x: 0, y: 1)
        .padding(.vertical, 16)
        .padding(.horizontal, 26)
        .modifier(LiquidGlassPill())
    }
}

/// Applies Apple's Liquid Glass effect (iOS 26+) with a graceful fallback
/// to .ultraThinMaterial on earlier versions.
private struct LiquidGlassPill: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                // Slight dark tint = still real Liquid Glass refraction,
                // but bright spots are muted enough that the label reads cleanly.
                .glassEffect(
                    .regular.tint(.black.opacity(0.18)),
                    in: Capsule()
                )
        } else {
            content
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().fill(Color.black.opacity(0.15)))
                .overlay(Capsule().stroke(Color.white.opacity(0.22), lineWidth: 0.8))
        }
    }
}
