//
//  TodayCard.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 20.12.2025.
//


import SwiftUI

// MARK: - Today Card (layout only)

struct TodayCard: View {
    @Binding var todayCount: Int

    // quick context
    @Binding var mood: MoodChoice
    @Binding var sleep: SleepChoice
    @Binding var stress: StressChoice

    // multi-select triggers
    @Binding var triggers: Set<TriggerChoice>

    // toggles
    @Binding var medsTaken: Bool
    @Binding var rescueUsed: Bool
    @Binding var injury: Bool

    @Binding var note: String

    // actions (wire later)
    
    var onUndoLast: () -> Void = { }
    var onAddSeizure: () -> Void = { } // optional if you want a button inside the card
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Header row
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
//                    Text("Today")
//                        .font(.headline)
//                        .foregroundColor(.white.opacity(0.92))

                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("\(todayCount)")
                            .font(.system(size: 52, weight: .bold))
                            .foregroundColor(.white)

                        Text("seizures")
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                Spacer()

                // Optional: quick undo + plus (or keep only bottom log button)
                VStack(spacing: 10) {

                        // ADD (plus) — on top
                        Button(action: onAddSeizure) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .frame(width: 36, height: 36)
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.white)
                        .background(.white.opacity(0.16), in: Circle())
                        .overlay(Circle().stroke(.white.opacity(0.20), lineWidth: 1))

                        // UNDO (minus) — below
                        Button {
                            print("Undo")
                            onUndoLast()
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 16, weight: .bold))
                                .frame(width: 36, height: 36)
                                .foregroundColor(.white)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.18))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }

            }

            Divider().opacity(0.25)

            // Mood / Sleep / Stress (single-select chips)
            VStack(alignment: .leading, spacing: 10) {
                ChipRowSingle(title: "Mood", selection: $mood, items: MoodChoice.allCases)
                ChipRowSingle(title: "Sleep", selection: $sleep, items: SleepChoice.allCases)
                ChipRowSingle(title: "Stress", selection: $stress, items: StressChoice.allCases)
            }

            // Triggers (multi-select chips)
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

// MARK: - Choices (for layout)

enum MoodChoice: String, CaseIterable, Identifiable {
    case good = "🙂 Good"
    case ok = "😐 OK"
    case low = "😟 Low"
    var id: String { rawValue }
}

enum SleepChoice: String, CaseIterable, Identifiable {
    case good = "Good"
    case ok = "OK"
    case poor = "Poor"
    var id: String { rawValue }
}

enum StressChoice: String, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    var id: String { rawValue }
}

enum TriggerChoice: String, CaseIterable, Identifiable, Hashable {
    case none = "None"
    case missedMeds = "Missed meds"
    case sleepDeprivation = "Sleep loss"
    case illness = "Illness"
    case alcohol = "Alcohol"
    case screen = "Screen"
    case period = "Period"
    case other = "Other"
    var id: String { rawValue }
}


// MARK: - UI building blocks

struct ChipRowSingle<T: CaseIterable & Identifiable & RawRepresentable>: View where T.RawValue == String {
    let title: String
    @Binding var selection: T
    let items: [T]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.75))

            HStack(spacing: 8) {
                ForEach(items) { item in
                    Chip(
                        title: item.rawValue,
                        isSelected: selection.id == item.id
                    ) {
                        selection = item
                    }
                }
            }
        }
    }
}

struct FlowChipsMulti<T: CaseIterable & Identifiable & RawRepresentable & Hashable>: View where T.RawValue == String {
    let items: [T]
    @Binding var selection: Set<T>

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 98), spacing: 8)], spacing: 8) {
            ForEach(items) { item in
                let isOn = selection.contains(item)
                Chip(title: item.rawValue, isSelected: isOn) {
                    if isOn { selection.remove(item) } else { selection.insert(item) }
                }
            }
        }
    }
}


struct Chip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(isSelected ? 0.95 : 0.78))
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.white.opacity(isSelected ? 0.20 : 0.10))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(.white.opacity(isSelected ? 0.30 : 0.16), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct ToggleRow: View {
    let title: String
    let systemImage: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white.opacity(0.88))
        }
        .tint(.white.opacity(0.85))
    }
}

#Preview {
    TrackerView(
        patientName: "Martina",
        onBack: {},
        store: EpiLogStore()
    )
}
