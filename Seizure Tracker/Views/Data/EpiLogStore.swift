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
    }

    // MARK: - Seizure actions

    func addSeizure() {
        seizures.append(SeizureEvent())
    }

    func undoLastSeizure() {
        _ = seizures.popLast()
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

struct SeizureEvent: Identifiable, Codable {
    let id: UUID
    let date: Date

    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
    }
}


//@MainActor
//final class EpiLogStore: ObservableObject {
//    @Published var patient: PatientProfile = .init() {
//        didSet { savePatient() }
//    }
//
//    private let patientKey = "epilog.patient.v1"
//
//    init() {
//        loadPatient()
//    }
//
//    private func savePatient() {
//        do {
//            let data = try JSONEncoder().encode(patient)
//            UserDefaults.standard.set(data, forKey: patientKey)
//        } catch {
//            print("❌ Failed to save patient:", error)
//        }
//    }
//
//    private func loadPatient() {
//        guard let data = UserDefaults.standard.data(forKey: patientKey) else { return }
//        do {
//            patient = try JSONDecoder().decode(PatientProfile.self, from: data)
//        } catch {
//            print("❌ Failed to load patient:", error)
//        }
//    }
//}
