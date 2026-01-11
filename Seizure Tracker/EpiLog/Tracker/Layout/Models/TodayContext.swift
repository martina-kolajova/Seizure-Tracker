//
//  MoodChoice.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 10.01.2026.
import Foundation
import SwiftUI

// enum: 
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
