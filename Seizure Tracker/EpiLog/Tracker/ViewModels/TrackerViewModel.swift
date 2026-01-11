//
//  TrackerViewModel.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 10.01.2026.
//

import Foundation
import SwiftUI

@MainActor
final class TrackerViewModel: ObservableObject {

    // 1) VM OWNS the store
    private let store: EpiLogStore
    var hourlyCounts12: [Int] {
        store.hourlyBins12(for: selectedDate)
    }

    // 2) VM exposes data the UI needs
    @Published var selectedDate: Date = Date()
    @Published var todayCount: Int = 0
    @Published var totalCount: Int = 0
    @Published var violetPhase: Double = 0
    @Published var selectedTab: TopTab = .tracker

    @Published var mood: MoodChoice = .ok
    @Published var sleep: SleepChoice = .ok
    @Published var stress: StressChoice = .medium
    @Published var triggers: Set<TriggerChoice> = []

    @Published var medsTaken: Bool = false
    @Published var rescueUsed: Bool = false
    @Published var injury: Bool = false
    @Published var note: String = ""


    init(store: EpiLogStore) {
        self.store = store
        syncCounts()
    }

    // ✅ moved from TrackerLayout
    func syncCounts() {
        todayCount = store.count(for: selectedDate)
        totalCount = store.totalCount()
    }

    // ✅ moved from TrackerLayout
    func logSeizure() {
        store.addSeizure(onDay: selectedDate)
        withAnimation(.easeInOut(duration: 0.8)) {
            violetPhase = min(violetPhase + 0.08, 1.0)
        }
        syncCounts()
    }

    // ✅ moved from TrackerLayout
    func undoLast() {
        _ = store.undoLastSeizure(onDay: selectedDate)
        withAnimation(.easeInOut(duration: 0.5)) {
            violetPhase = max(violetPhase - 0.06, 0.0)
        }
        syncCounts()
    }
    func generateReportText() -> String {
        let p = store.patient

        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short

        var lines: [String] = []
        lines.append("📄 Seizure Report")
        lines.append("")
        lines.append("Patient: \(p.firstName) \(p.lastName)")
        lines.append("Diagnosis: \(p.diagnosisText.isEmpty ? "—" : p.diagnosisText)")
        lines.append("Medication: \(p.medicationText.isEmpty ? "—" : p.medicationText)")
        lines.append("")
        lines.append("Total seizures: \(store.seizures.count)")
        lines.append("")

        if store.seizures.isEmpty {
            lines.append("No seizures logged.")
        } else {
            lines.append("Seizure timestamps:")
            for (i, ev) in store.seizures.enumerated() {
                lines.append("\(i + 1). \(df.string(from: ev.date))")
            }
        }

        return lines.joined(separator: "\n")
    }

}
