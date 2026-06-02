//
//  PatientPersonalViewModel.swift
//  EpiLog
//
//  Created by Martina Kolajová on 10.01.2026.
//
import Foundation
import Combine


@MainActor
final class PatientPersonalViewModel: ObservableObject {
    @Published var firstName: String
    @Published var lastName: String
    @Published var ageText: String
    @Published var heightValue: String
    @Published var weightValue: String
    @Published var heightUnit: HeightUnit
    @Published var weightUnit: WeightUnit
    @Published var personalNotes: String

    private let store: EpiLogStore

    init(store: EpiLogStore) {
        self.store = store
        let p = store.patient
        self.firstName = p.firstName
        self.lastName = p.lastName
        self.ageText = p.ageText
        self.heightValue = p.heightValue
        self.weightValue = p.weightValue
        self.heightUnit = p.heightUnit
        self.weightUnit = p.weightUnit
        self.personalNotes = p.personalNotes
    }

    func save() {
        store.patient.firstName = firstName
        store.patient.lastName = lastName
        store.patient.ageText = ageText
        store.patient.heightValue = heightValue
        store.patient.weightValue = weightValue
        store.patient.heightUnit = heightUnit
        store.patient.weightUnit = weightUnit
        store.patient.personalNotes = personalNotes
    }
}
