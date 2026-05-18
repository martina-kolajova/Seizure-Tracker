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
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
            Text(section.rawValue)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 26)
        .background(Color.white.opacity(0.20), in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.20), radius: 10, y: 5)
    }
}
