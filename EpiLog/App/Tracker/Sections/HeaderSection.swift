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
            Button {
                onBack()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                    .contentShape(Circle())
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
