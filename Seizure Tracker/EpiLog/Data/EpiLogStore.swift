//
//  EpiLogStore.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 02.01.2026.
//


import Foundation
import Combine


@MainActor
final class EpiLogStore: ObservableObject {

    // MARK: - Patient
    @Published var patient: PatientProfile = .init() {
        didSet { savePatient() }
    }

    // MARK: - Seizures
    @Published var seizures: [SeizureEvent] = [] {
        didSet { saveSeizures() }
    }

    // MARK: - Keys
    private let patientKey  = "epilog.patient.v1"
    private let seizuresKey = "epilog.seizures.v1"

    // MARK: - Init
    init() {
        loadPatient()
        loadSeizures()
        seizures.sort { $0.date < $1.date }
    }

    // MARK: - Day helper
    func dayKey(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    // MARK: - Seizure actions (existing)
    func addSeizure() {
        seizures.append(SeizureEvent())
        seizures.sort { $0.date < $1.date }
    }

    func undoLastSeizure() {
        _ = seizures.popLast()
    }

    func hourlyBins12(for day: Date) -> [Int] {
        var bins = Array(repeating: 0, count: 12)
        let cal = Calendar.current
        let key = cal.startOfDay(for: day)

        for e in seizures {
            if cal.startOfDay(for: e.date) == key {
                let hour24 = cal.component(.hour, from: e.date) // 0...23
                let h = hour24 % 12                              // 0...11
                bins[h] += 1
            }
        }
        return bins
    }


    // MARK: - Seizure actions (NEW: per selected day)

    /// Adds a seizure to the given day, using the current time-of-day.
    func addSeizure(onDay day: Date) {
        let cal = Calendar.current
        let start = cal.startOfDay(for: day)

        // keep current time-of-day (hour/min/sec)
        let now = Date()
        let time = cal.dateComponents([.hour, .minute, .second], from: now)

        let ts = cal.date(byAdding: time, to: start) ?? start
        seizures.append(SeizureEvent(date: ts))
        seizures.sort { $0.date < $1.date }
    }

    /// Removes the most recent seizure from the given day (if any).
    @discardableResult
    func undoLastSeizure(onDay day: Date) -> SeizureEvent? {
        let key = dayKey(day)
        guard let idx = seizures.lastIndex(where: { dayKey($0.date) == key }) else {
            return nil
        }
        return seizures.remove(at: idx)
    }

    // MARK: - Counts (useful for UI)

    func count(for day: Date) -> Int {
        let key = dayKey(day)
        return seizures.reduce(0) { $0 + (dayKey($1.date) == key ? 1 : 0) }
    }

    func totalCount() -> Int {
        seizures.count
    }

    // MARK: - Persistence (Patient)

    private func savePatient() {
        do {
            let data = try JSONEncoder().encode(patient)
            UserDefaults.standard.set(data, forKey: patientKey)
        } catch {
            print("❌ Failed to save patient:", error)
        }
    }

    private func loadPatient() {
        guard let data = UserDefaults.standard.data(forKey: patientKey) else { return }
        do {
            patient = try JSONDecoder().decode(PatientProfile.self, from: data)
        } catch {
            print("❌ Failed to load patient:", error)
        }
    }

    // MARK: - Persistence (Seizures)

    private func saveSeizures() {
        do {
            let data = try JSONEncoder().encode(seizures)
            UserDefaults.standard.set(data, forKey: seizuresKey)
        } catch {
            print("❌ Failed to save seizures:", error)
        }
    }

    private func loadSeizures() {
        guard let data = UserDefaults.standard.data(forKey: seizuresKey) else { return }
        do {
            seizures = try JSONDecoder().decode([SeizureEvent].self, from: data)
        } catch {
            print("❌ Failed to load seizures:", error)
        }
    }
}

// MARK: - Model

struct SeizureEvent: Identifiable, Codable {
    let id: UUID
    let date: Date

    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
    }
}



