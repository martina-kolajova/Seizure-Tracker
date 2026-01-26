//
//  TrackerViewModel.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 10.01.2026.
//

import Foundation
import SwiftUI

//  TrackerViewModel.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 10.01.2026.
//

import Foundation
import SwiftUI

@MainActor
final class TrackerViewModel: ObservableObject {

    // MARK: - Dependencies
    private let store: EpiLogStore

    // MARK: - UI State
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

    // MARK: - Init
    init(store: EpiLogStore) {
        self.store = store
        syncCounts()
        syncVioletPhaseFromLatestEvent()
    }

    // MARK: - Chart output (Counts + Frozen Colors)

    /// Returns seizure counts per 12-hour bin AND frozen colors per bin
    /// based on the latest logged seizure in that bin (latest wins).
    func distribution12() -> (counts: [Int], perBinColors: [Color]) {
        let (counts, latestPhase) = store.hourlyBins12WithLatestPhase(for: selectedDate)

        let perBinColors: [Color] = latestPhase.map { phase in
            let p = max(0, min(1, phase ?? 0))
            let hue: Double = 0.78
            let saturation = 0.35 + 0.50 * p
            let brightness = 0.98 - 0.45 * p
            return Color(hue: hue, saturation: saturation, brightness: brightness)
        }

        return (counts, perBinColors)
    }

    // MARK: - Counts

    func syncCounts() {
        todayCount = store.count(for: selectedDate)
        totalCount = store.totalCount()
    }

    // MARK: - Seizure actions

    func logSeizure() {
        let phaseAtTap = violetPhase
        store.addSeizure(onDay: selectedDate, tintPhase: phaseAtTap)

        withAnimation(.easeInOut(duration: 0.8)) {
            violetPhase = min(violetPhase + 0.08, 1.0)
        }

        syncCounts()
        // no need to syncVioletPhaseFromLatestEvent() here; we know we just logged one
    }

    func undoLast() {
        _ = store.undoLastSeizure(onDay: selectedDate)

        // ✅ keep violetPhase consistent with "latest logged wins"
        withAnimation(.easeInOut(duration: 0.5)) {
            syncVioletPhaseFromLatestEvent()
        }

        syncCounts()
    }

    // MARK: - Keep violetPhase in sync with data

    private func syncVioletPhaseFromLatestEvent() {
        let cal = Calendar.current
        let key = cal.startOfDay(for: selectedDate)

        if let last = store.seizures.last(where: { cal.startOfDay(for: $0.date) == key }) {
            violetPhase = last.tintPhase
        } else {
            violetPhase = 0
        }
    }

    // If user changes selected date, call this from the View (you already call syncCounts)
    func onSelectedDateChanged() {
        syncCounts()
        syncVioletPhaseFromLatestEvent()
    }

    // MARK: - Report
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
