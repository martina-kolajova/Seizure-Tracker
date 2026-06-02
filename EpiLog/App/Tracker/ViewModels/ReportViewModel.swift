//
//  ReportViewModel.swift
//  Seizure Tracker
//
//  All derived stats and formatting for ReportView.
//  Keeps ReportView a pure layout file (no Calendar / Date math in body).
//

import Foundation
import SwiftUI

// MARK: - Lightweight data models exposed to the view

struct DayCount: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct HourBucket: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let count: Int
}

// MARK: - ViewModel

@MainActor
final class ReportViewModel: ObservableObject {

    // Inputs
    let store: EpiLogStore
    let shareText: String

    init(store: EpiLogStore, shareText: String) {
        self.store = store
        self.shareText = shareText
    }

    // MARK: Patient header
    var patientName: String {
        let p = store.patient
        let n = "\(p.firstName) \(p.lastName)".trimmingCharacters(in: .whitespaces)
        return n.isEmpty ? "—" : n
    }

    var diagnosisCode: String? { splitDiagnosis(store.patient.diagnosisText).code }

    // MARK: Totals
    var totalCount: Int { store.seizures.count }
    var weekTotal: Int { last7DaysCounts.reduce(0) { $0 + $1.count } }
    var monthTotal: Int { last30DaysCounts.reduce(0) { $0 + $1.count } }

    var weeklyAverage: Double {
        last7DaysCounts.isEmpty ? 0 : Double(weekTotal) / 7.0
    }

    var daysSeizureFreeThisWeek: Int {
        last7DaysCounts.filter { $0.count == 0 }.count
    }

    var weeklyAverageDisplay: String { String(format: "%.1f", weeklyAverage) }

    // MARK: Series
    var last7DaysCounts: [DayCount] { dayCounts(days: 7) }
    var last30DaysCounts: [DayCount] { dayCounts(days: 30) }

    var hourBuckets: [HourBucket] {
        var counts = Array(repeating: 0, count: 6) // 0-3, 4-7, 8-11, 12-15, 16-19, 20-23
        let cal = Calendar.current
        for ev in store.seizures {
            let h = cal.component(.hour, from: ev.date)
            counts[h / 4] += 1
        }
        let labels = ["0-3", "4-7", "8-11", "12-15", "16-19", "20-23"]
        return zip(labels, counts).map { HourBucket(label: $0.0, count: $0.1) }
    }

    var recentEvents: [SeizureEvent] {
        Array(store.seizures.suffix(8).reversed())
    }

    // MARK: Helpers
    private func dayCounts(days: Int) -> [DayCount] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<days).reversed().map { offset in
            let day = cal.date(byAdding: .day, value: -offset, to: today) ?? today
            return DayCount(date: day, count: store.count(for: day))
        }
    }

    /// Parses "Epilepsy, unspecified (G40.909)" → ("Epilepsy, unspecified", "G40.909").
    private func splitDiagnosis(_ text: String) -> (name: String, code: String?) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasSuffix(")"),
              let open = trimmed.lastIndex(of: "(")
        else { return (trimmed, nil) }
        let code = String(trimmed[trimmed.index(after: open)..<trimmed.index(before: trimmed.endIndex)])
        let name = String(trimmed[..<open]).trimmingCharacters(in: .whitespaces)
        return (name, code.isEmpty ? nil : code)
    }
}
