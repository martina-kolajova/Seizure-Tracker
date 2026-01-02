//
//  TodayCardContainer.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 20.12.2025.
//

import SwiftUI

struct TodayCardContainer: View {
    @Binding var todayCount: Int
    @Binding var showDetails: Bool   // kept for compatibility, but we won’t use it

    // pass-through bindings
    @Binding var mood: MoodChoice
    @Binding var sleep: SleepChoice
    @Binding var stress: StressChoice
    @Binding var triggers: Set<TriggerChoice>
    @Binding var medsTaken: Bool
    @Binding var rescueUsed: Bool
    @Binding var injury: Bool
    @Binding var note: String

    let onUndoLast: () -> Void
    let onAddSeizure: () -> Void

    var body: some View {
        VStack(spacing: 14) {

            // ✅ Header is visible, but NOT collapsible
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today at a glance")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.92))

                }

                Spacer()

                // optional quick indicators (keep if you like)
                HStack(spacing: 10) {
                    Image(systemName: medsTaken ? "pills.fill" : "pills")
                        .foregroundColor(.white.opacity(0.75))

                    Image(systemName: sleep == .good ? "bed.double.fill" : "bed.double")
                        .foregroundColor(.white.opacity(0.75))

                    // ❌ removed chevron (no collapse anymore)
                }
            }

            Divider().opacity(0.25)

            // ✅ Always visible menu/details
            TodayCard(
                todayCount: $todayCount,
                mood: $mood,
                sleep: $sleep,
                stress: $stress,
                triggers: $triggers,
                medsTaken: $medsTaken,
                rescueUsed: $rescueUsed,
                injury: $injury,
                note: $note,
                onUndoLast: onUndoLast,
                onAddSeizure: onAddSeizure
            )
        }
        .onAppear {
            // ✅ ensure it never collapses if something else toggles it
            showDetails = true
        }
    }
}
