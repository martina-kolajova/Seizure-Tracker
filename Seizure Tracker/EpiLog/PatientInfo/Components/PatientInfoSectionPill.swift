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
        HStack(spacing: 8) {
            Image(systemName: section.iconName)
            Text(section.rawValue)
                .font(.subheadline)
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 10, y: 6)
    }
}
