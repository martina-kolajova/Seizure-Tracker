//
//  PatientInfoView 2.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 16.12.2025.
//


import SwiftUI

struct PatientDelegate: View {
    @Binding var patientName: String

    let onContinue: () -> Void
    let onBack: () -> Void

    @State private var path: [InfoSection]

    init(
        patientName: Binding<String>,
        onContinue: @escaping () -> Void,
        onBack: @escaping () -> Void,
        initialSection: InfoSection? = nil
    ) {
        self._patientName = patientName
        self.onContinue = onContinue
        self.onBack = onBack
        self._path = State(initialValue: initialSection.map { [$0] } ?? [])
    }

    // Personal
    @State private var personalNotes: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var ageText: String = ""
    @State private var heightValue: String = ""
    @State private var weightValue: String = ""
    @State private var heightUnit: HeightUnit = .cm
    @State private var weightUnit: WeightUnit = .kg

    // Diagnosis
    @State private var diagnosisText: String = ""
    @State private var diagnosisYear: String = ""
    @FocusState private var diagnosisFocused: Bool
    @State private var didPickDiagnosis: Bool = false

    // Medication
    @State private var medicationText: String = ""
    @State private var extraNotes: String = ""

    // Services
    @StateObject private var icdService = ICD10Service()
    @StateObject private var drugService = DrugLabelService()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                MeshGradientView().ignoresSafeArea()

                PatientInfoMenuView(
                    onBack: onBack,
                    onContinue: onContinue
                )
            }
            .navigationDestination(for: InfoSection.self) { section in
                switch section {
                case .personal:
                    PatientInfoPersonalView(
                        firstName: $firstName,
                        lastName: $lastName,
                        ageText: $ageText,
                        heightValue: $heightValue,
                        weightValue: $weightValue,
                        heightUnit: $heightUnit,
                        weightUnit: $weightUnit,
                        personalNotes: $personalNotes
                    )

                case .diagnosis:
                    PatientInfoDiagnosisView(
                        diagnosisText: $diagnosisText,
                        diagnosisYear: $diagnosisYear,
                        icdService: icdService
                    )

                case .medication:
                    PatientInfoMedicationView(
                        medicationText: $medicationText,
                        extraNotes: $extraNotes,
                        drugService: drugService
                    )
                }
            }
        }
    }
}

#Preview {
    PatientDelegate(
        patientName: .constant("Anna Preview"),
        onContinue: { },
        onBack: { }
    )
}
