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
import Security


@MainActor
final class EpiLogStore: ObservableObject {

    // MARK: - Patient
    @Published var patient: PatientProfile = .init()

    // MARK: - Seizures
    @Published var seizures: [SeizureEvent] = []

    // MARK: - Persistence Keys
    private let patientKey  = "epilog.patient.v1"
    private let seizuresKey = "epilog.seizures.v1"

    private var cancellables = Set<AnyCancellable>()
    private var isLoading = false

    init() {
        isLoading = true
        loadPatient()
        loadSeizures()
        seizures.sort { $0.date < $1.date }
        isLoading = false

        // Autosave (debounced)
        $patient
            .dropFirst()
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.savePatientIfNeeded() }
            .store(in: &cancellables)

        $seizures
            .dropFirst()
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.saveSeizuresIfNeeded() }
            .store(in: &cancellables)
    }

    // MARK: - Date Helpers
    func dayKey(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    // MARK: - Actions
    func addSeizure(tintPhase: Double) {
        seizures.append(SeizureEvent(tintPhase: tintPhase))
        seizures.sort { $0.date < $1.date }
    }

    func addSeizure(onDay day: Date, tintPhase: Double) {
        let cal = Calendar.current
        let start = cal.startOfDay(for: day)

        let now = Date()
        let time = cal.dateComponents([.hour, .minute, .second], from: now)
        let ts = cal.date(byAdding: time, to: start) ?? start

        seizures.append(SeizureEvent(date: ts, tintPhase: tintPhase))
        seizures.sort { $0.date < $1.date }
    }


    @discardableResult
    func undoLastSeizure(onDay day: Date) -> SeizureEvent? {
        let key = dayKey(day)
        guard let idx = seizures.lastIndex(where: { dayKey($0.date) == key }) else { return nil }
        return seizures.remove(at: idx)
    }

    func count(for day: Date) -> Int {
        let key = dayKey(day)
        return seizures.reduce(0) { $0 + (dayKey($1.date) == key ? 1 : 0) }
    }

    func totalCount() -> Int { seizures.count }

    
    func hourlyBins24(for day: Date) -> [Int] {
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
    func hourlyBins12WithLatestPhase(for day: Date) -> (counts: [Int], latestPhase: [Double?]) {
        var counts = Array(repeating: 0, count: 12)
        var latest = Array<Double?>(repeating: nil, count: 12)

        let cal = Calendar.current
        let key = cal.startOfDay(for: day)

        // seizures are sorted by date in your store
        for e in seizures where cal.startOfDay(for: e.date) == key {
            let bin = cal.component(.hour, from: e.date) % 12
            counts[bin] += 1
            latest[bin] = e.tintPhase   // 
        }

        return (counts, latest)
    }

    
    
    // MARK: - Persistence
    private func savePatientIfNeeded() {
        guard !isLoading else { return }
        do {
            let data = try JSONEncoder().encode(patient)
            let success = KeychainManager.shared.save(data: data, forKey: patientKey)
            if !success {
                print("Failed to save patient to Keychain")
            }
        } catch {
            print("Failed to encode patient:", error)
        }
    }

    private func loadPatient() {
        guard let data = KeychainManager.shared.load(forKey: patientKey) else { return }
        do {
            patient = try JSONDecoder().decode(PatientProfile.self, from: data)
        } catch {
            print("Failed to decode patient:", error)
        }
    }

    private func saveSeizuresIfNeeded() {
        guard !isLoading else { return }
        do {
            let data = try JSONEncoder().encode(seizures)
            let success = KeychainManager.shared.save(data: data, forKey: seizuresKey)
            if !success {
                print("Failed to save seizures to Keychain")
            }
        } catch {
            print("Failed to encode seizures:", error)
        }
    }

    private func loadSeizures() {
        guard let data = KeychainManager.shared.load(forKey: seizuresKey) else { return }
        do {
            seizures = try JSONDecoder().decode([SeizureEvent].self, from: data)
        } catch {
            print("Failed to decode seizures:", error)
        }
    }
    
    // MARK: - GDPR: Delete all user data
    /// Securely deletes all patient data from Keychain (GDPR compliance).
    @MainActor
    func deleteAllUserData() {
        KeychainManager.shared.deleteAll()
        patient = .init()
        seizures = []
    }
}

// MARK: - Model


struct SeizureEvent: Identifiable, Codable {
    let id: UUID
    let date: Date
    let tintPhase: Double   // 0...1 captured at logging time

    init(date: Date = Date(), tintPhase: Double = 0) {
        self.id = UUID()
        self.date = date
        self.tintPhase = tintPhase
    }

    // Backward-compatible decoding (older saves won't have tintPhase)
    enum CodingKeys: String, CodingKey { case id, date, tintPhase }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(UUID.self, forKey: .id)
        self.date = try c.decode(Date.self, forKey: .date)
        self.tintPhase = try c.decodeIfPresent(Double.self, forKey: .tintPhase) ?? 0
    }
}

//struct SeizureEvent: Identifiable, Codable {
//    let id: UUID
//    let date: Date
//
//    init(date: Date = Date()) {
//        self.id = UUID()
//        self.date = date
//    }
//}

