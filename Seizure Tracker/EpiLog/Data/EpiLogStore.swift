//
//  EpiLogStore.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 02.01.2026.
//
//  Shared ObservableObject acting as a central ViewModel / data store
//  for multiple SwiftUI screens (simple MVVM approach).
//

import Foundation
import Combine

/// Main application store holding patient data and seizure events.
/// Handles state, business logic, and persistence.
/// Views observe this object and react to state changes.
@MainActor
final class EpiLogStore: ObservableObject {

    // MARK: - Patient

    /// Patient profile shared across the app.
    /// Automatically persisted on change.
    @Published var patient: PatientProfile = .init() {
        didSet { savePatient() }
    }

    // MARK: - Seizures

    /// List of all recorded seizure events.
    /// Automatically persisted on change.
    @Published var seizures: [SeizureEvent] = [] {
        didSet { saveSeizures() }
    }

    // MARK: - Persistence Keys

    /// UserDefaults keys for persisted data.
    private let patientKey  = "epilog.patient.v1"
    private let seizuresKey = "epilog.seizures.v1"

    // MARK: - Init

    /// Loads persisted data on app launch.
    init() {
        loadPatient()
        loadSeizures()
        seizures.sort { $0.date < $1.date }
    }

    // MARK: - Date Helpers

    /// Returns a normalized start-of-day key for date-based grouping.
    func dayKey(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    // MARK: - Seizure Actions (Global)

    /// Adds a new seizure event with the current timestamp.
    func addSeizure() {
        seizures.append(SeizureEvent())
        seizures.sort { $0.date < $1.date }
    }

//    /// Removes the most recently added seizure event.
//    func undoLastSeizure() {
//        _ = seizures.popLast()
//    }

    /// Groups seizures into 12 hourly bins for a given day (used for charts).
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

    // MARK: - Seizure Actions (Per Selected Day)

    /// Adds a seizure to a selected day while keeping the current time-of-day.
    func addSeizure(onDay day: Date) {
        let cal = Calendar.current
        let start = cal.startOfDay(for: day)

        let now = Date()
        let time = cal.dateComponents([.hour, .minute, .second], from: now)

        let ts = cal.date(byAdding: time, to: start) ?? start
        seizures.append(SeizureEvent(date: ts))
        seizures.sort { $0.date < $1.date }
    }

    /// Removes the most recent seizure from the selected day, if any.
    @discardableResult
    func undoLastSeizure(onDay day: Date) -> SeizureEvent? {
        let key = dayKey(day)
        guard let idx = seizures.lastIndex(where: { dayKey($0.date) == key }) else {
            return nil
        }
        return seizures.remove(at: idx)
    }

    // MARK: - Counts (UI Helpers)

    /// Returns the number of seizures recorded on a given day.
    func count(for day: Date) -> Int {
        let key = dayKey(day)
        return seizures.reduce(0) { $0 + (dayKey($1.date) == key ? 1 : 0) }
    }

    /// Returns the total number of recorded seizures.
    func totalCount() -> Int {
        seizures.count
    }

    // MARK: - Persistence (Patient)

    /// Saves patient data to UserDefaults.
    private func savePatient() {
        do {
            let data = try JSONEncoder().encode(patient)
            UserDefaults.standard.set(data, forKey: patientKey)
        } catch {
            print("Failed to save patient:", error)
        }
    }

    /// Loads patient data from UserDefaults.
    private func loadPatient() {
        guard let data = UserDefaults.standard.data(forKey: patientKey) else { return }
        do {
            patient = try JSONDecoder().decode(PatientProfile.self, from: data)
        } catch {
            print("Failed to load patient:", error)
        }
    }

    // MARK: - Persistence (Seizures)

    /// Saves seizure events to UserDefaults.
    private func saveSeizures() {
        do {
            let data = try JSONEncoder().encode(seizures)
            UserDefaults.standard.set(data, forKey: seizuresKey)
        } catch {
            print("Failed to save seizures:", error)
        }
    }

    /// Loads seizure events from UserDefaults.
    private func loadSeizures() {
        guard let data = UserDefaults.standard.data(forKey: seizuresKey) else { return }
        do {
            seizures = try JSONDecoder().decode([SeizureEvent].self, from: data)
        } catch {
            print("Failed to load seizures:", error)
        }
    }
}

// MARK: - Model

/// Basic seizure event model.
struct SeizureEvent: Identifiable, Codable {
    let id: UUID
    let date: Date

    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
    }
}


