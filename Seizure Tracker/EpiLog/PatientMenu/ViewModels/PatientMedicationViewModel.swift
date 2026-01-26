//
//  PatientMedicationViewModel.swift
//  EpiLog
//
//  Created by Martina Kolajová on 10.01.2026.
//
import Foundation
import Combine


@MainActor
final class PatientMedicationViewModel: ObservableObject {
    @Published var medicationText: String
    @Published var medicationNotes: String
    @Published var suggestions: [DrugSuggestion] = []

    private let store: EpiLogStore
    private let drugService: DrugLabelService

    init(store: EpiLogStore, drugService: DrugLabelService) {
        self.store = store
        self.drugService = drugService
        self.medicationText = store.patient.medicationText
        self.medicationNotes = store.patient.medicationNotes
    }

    func onMedicationChanged(_ text: String) {
        drugService.search(term: text)
        suggestions = drugService.suggestions
    }

    func pickSuggestion(_ s: DrugSuggestion) {
        medicationText = s.displayName
        suggestions = []
    }

    func save() {
        store.patient.medicationText = medicationText
        store.patient.medicationNotes = medicationNotes
    }
}
