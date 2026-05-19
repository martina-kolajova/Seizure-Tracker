//
//  PatientDiagnosisViewModel.swift
//  EpiLog
//
//  Created by Martina Kolajová on 25.01.2026.
//



import Foundation
import Combine

@MainActor
final class PatientDiagnosisViewModel: ObservableObject {

    // MARK: - Published state

    @Published var diagnosisText: String
    @Published var diagnosisYear: String
    @Published var suggestions: [ICDSuggestion] = []

    // MARK: - Dependencies

    private let store: EpiLogStore
    private let icdService: ICD10Service
    private var suppressNextSearch = false   //

    // MARK: - Init

    init(store: EpiLogStore, icdService: ICD10Service) {
        self.store = store
        self.icdService = icdService

        // Load initial values from persisted patient profile
        self.diagnosisText = store.patient.diagnosisText
        self.diagnosisYear = store.patient.diagnosisYear

        // Keep VM suggestions in sync with the service (reactive binding)
        icdService.$suggestions
            .receive(on: RunLoop.main)
            .assign(to: &$suggestions)
    }

    // MARK: - User actions

    /// Called from the View when the user types.
    /// NOTE: Do NOT write back to `diagnosisText` here, or you'll create an update loop.
    func onDiagnosisChanged(_ text: String) {
         if suppressNextSearch {              //
             suppressNextSearch = false
             return
         }
         icdService.search(term: text)
     }

     func pickSuggestion(_ s: ICDSuggestion) {
         suppressNextSearch = true
         diagnosisText = "\(s.name) (\(s.code))"
         suggestions = []
         icdService.search(term: "")
     }
    /// Persist changes to the shared store (called onDisappear).
    func save() {
        store.patient.diagnosisText = diagnosisText
        store.patient.diagnosisYear = diagnosisYear
    }
}
