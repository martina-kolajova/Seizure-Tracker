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
    @Published var patient: PatientProfile = .init() {
        didSet { savePatient() }
    }

    private let patientKey = "epilog.patient.v1"

    init() {
        loadPatient()
    }

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
}
