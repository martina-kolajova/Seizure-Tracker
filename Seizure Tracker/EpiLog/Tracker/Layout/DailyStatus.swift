//
//  TodayCard.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 20.12.2025.
//


import SwiftUI


struct DailyStatus: View {
    // display-only
    let todayCount: Int

    // context bindings
    @Binding var mood: MoodChoice
    @Binding var sleep: SleepChoice
    @Binding var stress: StressChoice
    @Binding var triggers: Set<TriggerChoice>

    @Binding var medsTaken: Bool
    @Binding var rescueUsed: Bool
    @Binding var injury: Bool
    @Binding var note: String

    // actions
    let onUndoLast: () -> Void
    let onGenerateReport: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Header
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today at a glance")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.92))
                }

                Spacer()

                Button(action: onGenerateReport) {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text")
                        Text("Report")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.18))
                    )
                }
                .buttonStyle(.plain)
            }

            Divider().opacity(0.25)

            // Count row + Undo
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("\(todayCount)")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundColor(.white)

                Text("seizures")
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                Button(action: onUndoLast) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 36, height: 36)
                        .foregroundColor(.white)
                        .background(.white.opacity(0.16), in: Circle())
                        .overlay(Circle().stroke(.white.opacity(0.20), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }

            Divider().opacity(0.25)

            // Mood / Sleep / Stress
            VStack(alignment: .leading, spacing: 10) {
                ChipRowSingle(title: "Mood", selection: $mood, items: MoodChoice.allCases)
                ChipRowSingle(title: "Sleep", selection: $sleep, items: SleepChoice.allCases)
                ChipRowSingle(title: "Stress", selection: $stress, items: StressChoice.allCases)
            }

            // Triggers
            VStack(alignment: .leading, spacing: 8) {
                Text("Triggers")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.75))

                FlowChipsMulti(items: TriggerChoice.allCases, selection: $triggers)
            }

            // Toggles
            VStack(spacing: 8) {
                ToggleRow(title: "Meds taken today", systemImage: "pills.fill", isOn: $medsTaken)
                ToggleRow(title: "Rescue medication used", systemImage: "cross.case.fill", isOn: $rescueUsed)
                ToggleRow(title: "Injury occurred", systemImage: "bandage.fill", isOn: $injury)
            }

            // Note
            VStack(alignment: .leading, spacing: 6) {
                Text("Note (optional)")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.75))

                TextField("e.g., aura, context, meds change…", text: $note, axis: .vertical)
                    .lineLimit(1...3)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(.white.opacity(0.18), lineWidth: 1)
                    )
                    .foregroundColor(.white.opacity(0.95))
            }
        }
    }
}


#Preview {
    TrackerView(
        patientName: "Martina",
        onBack: {},
        store: EpiLogStore()
    )
}
