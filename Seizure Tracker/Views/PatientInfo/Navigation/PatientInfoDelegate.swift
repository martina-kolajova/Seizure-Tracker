//
//  PatientInfoView 2.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 16.12.2025.
//


import SwiftUI



struct PatientDelegate: View {

    @ObservedObject var store: EpiLogStore
    let onBack: () -> Void
    let onContinue: () -> Void

    // ✅ keep services alive (better for previews + avoids repeated init)
    @StateObject private var icdService = ICD10Service()
    @StateObject private var drugService = DrugLabelService()

    var body: some View {
        NavigationStack {
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
                    PatientInfoPersonalView(store: store)

                case .diagnosis:
                    PatientInfoDiagnosisView(
                        store: store,
                        icdService: icdService
                    )

                case .medication:
                    PatientInfoMedicationView(
                        store: store,
                        drugService: drugService
                    )
                }
            }
        }
    }
}

#Preview("PatientDelegate") {
    PatientDelegate(
        store: EpiLogStore(),
        onBack: { print("Back tapped") },
        onContinue: { print("Continue tapped") }
    )
}
