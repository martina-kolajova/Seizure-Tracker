//
//  header.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 03.01.2026.
//

import SwiftUI

extension TrackerLayout {

    // MARK: - Header
    var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
            }
            .buttonStyle(.plain)

            Spacer()

            Text(patientName.isEmpty ? "Patient" : patientName)
                .foregroundColor(.white.opacity(0.95))
                .font(.headline)

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
    }
}
