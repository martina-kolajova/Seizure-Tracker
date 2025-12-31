//
//  TodayCardContainer.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 20.12.2025.
//

import SwiftUI



struct TodayCardContainer: View {
    @Binding var todayCount: Int
    @Binding var showDetails: Bool

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

            // 🔹 COLLAPSED HEADER (always visible)
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    showDetails.toggle()
                }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Today at a glance")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.92))

                        Text("\(todayCount) seizures")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.70))
                    }

                    Spacer()

                    // keep just 1–2 indicators here (optional)
                    HStack(spacing: 10) {
                        Image(systemName: medsTaken ? "pills.fill" : "pills")
                            .foregroundColor(.white.opacity(0.75))

                        Image(systemName: sleep == .good ? "bed.double.fill" : "bed.double")
                            .foregroundColor(.white.opacity(0.75))

                        Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                            .foregroundColor(.white.opacity(0.65))
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
                .contentShape(Rectangle())   // makes the whole row tappable
            }
            .buttonStyle(.plain)

            // 🔹 EXPANDED DETAILS
            if showDetails {
                Divider().opacity(0.25)

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
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Quick icons (optional helpers)

    private func quickIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 14, weight: .semibold))
            .frame(width: 28, height: 28)
            .background(.white.opacity(0.14), in: Circle())
            .foregroundColor(.white.opacity(0.9))
    }

    private var moodIcon: String {
        switch mood {
        case .good: return "face.smiling"
        case .ok:   return "face.neutral"
        case .low:  return "face.dashed"
        }
    }

    private var sleepIcon: String {
        sleep == .good ? "bed.double.fill" : "bed.double"
    }

    private var stressIcon: String {
        stress == .low ? "leaf.fill" : "exclamationmark.triangle"
    }
}
