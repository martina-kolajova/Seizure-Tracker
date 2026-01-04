//
//  distributionCard.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 03.01.2026.
//

import SwiftUI

extension TrackerLayout {

    // MARK: - Distribution card (donut ring)
    var distributionCard: some View {
        let maxPerHour = max(1, hourlyCounts.max() ?? 1)

        let p = max(0, min(1, violetPhase))
        let hue: Double = 0.78
        let saturation = 0.35 + 0.50 * p
        let brightness = 0.98 - 0.45 * p

        let barColor = Color(hue: hue, saturation: saturation, brightness: brightness)

        return VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Daily seizure distribution")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.9))

                Text("By hour")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.65))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Spacer()

                DonutRadialBarRingWithClockLabels(
                    values: hourlyCounts,
                    maxValue: maxPerHour,
                    barColor: barColor
                )
                .frame(width: 220, height: 220)

                Spacer()
            }
        }
    }
}
