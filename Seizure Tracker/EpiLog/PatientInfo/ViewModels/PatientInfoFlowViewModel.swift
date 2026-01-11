//
//  PatientInfoFlowViewModel.swift
//  EpiLog
//
//  Created by Martina Kolajová on 10.01.2026.
//

import Foundation
import Combine

@MainActor
final class PatientInfoFlowViewModel: ObservableObject {
    let store: EpiLogStore
    let icdService: ICD10Service
    let drugService: DrugLabelService

    private lazy var personalVM = PatientPersonalViewModel(store: store)
    private lazy var diagnosisVM = PatientDiagnosisViewModel(store: store, icdService: icdService)
    private lazy var medicationVM = PatientMedicationViewModel(store: store, drugService: drugService)

    init(store: EpiLogStore,
         icdService: ICD10Service? = nil,
         drugService: DrugLabelService? = nil) {
        self.store = store
        self.icdService = icdService ?? ICD10Service()
        self.drugService = drugService ?? DrugLabelService()
    }


    func makePersonalVM() -> PatientPersonalViewModel { personalVM }
    func makeDiagnosisVM() -> PatientDiagnosisViewModel { diagnosisVM }
    func makeMedicationVM() -> PatientMedicationViewModel { medicationVM }
}
