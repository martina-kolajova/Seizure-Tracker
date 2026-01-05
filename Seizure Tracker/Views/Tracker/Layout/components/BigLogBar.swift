//
//  BigLogBar.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 03.01.2026.
//


import SwiftUI

struct BigLogBar: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image("logo-white")
                .resizable()
                .scaledToFit()
                .padding(1)
                .frame(width: 102, height: 102)
                .foregroundColor(.white)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .shadow(radius: 12, y: 6)
        .accessibilityLabel("Log")
    }
}
