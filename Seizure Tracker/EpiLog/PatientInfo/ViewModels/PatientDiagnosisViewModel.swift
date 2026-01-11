//
//  PatientDiagnosisViewModel.swift
//  EpiLog
//
//  Created by Martina Kolajová on 10.01.2026.
//
import Foundation
import Combine


@MainActor
final class PatientDiagnosisViewModel: ObservableObject {
    @Published var diagnosisText: String
    @Published var diagnosisYear: String
    @Published var suggestions: [ICDSuggestion] = []

    private let store: EpiLogStore
    private let icdService: ICD10Service

    init(store: EpiLogStore, icdService: ICD10Service) {
        self.store = store
        self.icdService = icdService
        self.diagnosisText = store.patient.diagnosisText
        self.diagnosisYear = store.patient.diagnosisYear
    }

    func onDiagnosisChanged(_ text: String) {
        icdService.search(term: text)
        suggestions = icdService.suggestions
    }

    func pickSuggestion(_ s: ICDSuggestion) {
        diagnosisText = "\(s.code) – \(s.name)"
        suggestions = []
    }

    func save() {
        store.patient.diagnosisText = diagnosisText
        store.patient.diagnosisYear = diagnosisYear
    }
}
