//
//  distributionCard.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 03.01.2026.
//

import SwiftUI


extension TrackerLayout {

    var distributionCard: some View {
        let hourlyCounts = vm.hourlyCounts12  // ✅ from VM

        let colorCap = 6

        let p = max(0, min(1, vm.violetPhase)) // ✅ from VM
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
                    maxValue: colorCap,
                    barColor: barColor
                )
                .frame(width: 220, height: 220)
                Spacer()
            }
        }
    }
}
