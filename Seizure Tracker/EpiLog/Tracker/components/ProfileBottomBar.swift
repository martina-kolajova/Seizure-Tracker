//
//  ProfileBottomBar.swift
//
//  Created by Martina Kolajová on 16.12.2025.
//


import SwiftUI

struct ProfileBottomBar: View {
    @Binding var activeTab: TrackerView.ProfileTab?

    var body: some View {
        HStack(spacing: 10) {
            barButton("Personal", systemImage: "heart.text.square") { activeTab = .personal }
            barButton("Diagnosis", systemImage: "waveform.path.ecg") { activeTab = .diagnosis }
            barButton("Meds", systemImage: "pills.fill") { activeTab = .medication }
        }
        .padding(10)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1))
        .shadow(color: .black.opacity(0.35), radius: 16, y: 8)
    }

    private func barButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title).font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(Color.white.opacity(0.12), in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
