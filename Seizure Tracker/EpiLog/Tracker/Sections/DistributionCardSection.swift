//
//  distributionCard.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 03.01.2026.
//


import SwiftUI


extension TrackerLayout {

    var distributionCard: some View {

        let colorCap = 6

        //  Current bin (0...11), where 0 == "12"
        let hour24 = Calendar.current.component(.hour, from: Date())
        let currentBin = hour24 % 12

        //  Counts + frozen per-bin colors (latest logged wins) come from the VM
        let out = vm.distribution12()
        let hourlyCounts = out.counts
        let perBinColors = out.perBinColors

        //  Only current bin override color
        let currentColor = Color.purple

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
                    barColor: .white,           // fallback only
                    currentColor: currentColor, // only current bin
                    currentIndex: currentBin,
                    perBinColors: perBinColors  //  frozen colors per bin
                )
                .frame(width: 220, height: 220)
                Spacer()
            }
        }
    }
}
