//
//  PatientInfoView 2.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 16.12.2025.
//


import SwiftUI

struct PatientInfoFlowView: View {
    let onBack: () -> Void
    let onContinue: () -> Void

    @StateObject private var vm: PatientInfoFlowViewModel

    init(store: EpiLogStore, onBack: @escaping () -> Void, onContinue: @escaping () -> Void) {
        self.onBack = onBack
        self.onContinue = onContinue
        _vm = StateObject(wrappedValue: PatientInfoFlowViewModel(store: store))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MeshGradientView().ignoresSafeArea()

                PatientInfoMenuView(onBack: onBack, onContinue: onContinue) // unchanged :contentReference[oaicite:2]{index=2}
            }
            .navigationDestination(for: InfoSection.self) { section in
                switch section {
                case .personal:
                    PatientInfoPersonalView(vm: vm.makePersonalVM())
                case .diagnosis:
                    PatientInfoDiagnosisView(vm: vm.makeDiagnosisVM())
                case .medication:
                    PatientInfoMedicationView(vm: vm.makeMedicationVM())
                }
            }
        }
    }
}


//
//struct PatientInfoFlowView: View {
//
//    @ObservedObject var store: EpiLogStore
//    let onBack: () -> Void
//    let onContinue: () -> Void
//
//    // ✅ keep services alive (better for previews + avoids repeated init)
//    @StateObject private var icdService = ICD10Service()
//    @StateObject private var drugService = DrugLabelService()
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                MeshGradientView().ignoresSafeArea()
//                
//
//                PatientInfoMenuView(
//                    onBack: onBack,
//                    onContinue: onContinue
//                )
//            }
//            .navigationDestination(for: InfoSection.self) { section in
//                switch section {
//                case .personal:
//                    PatientInfoPersonalView(store: store)
//
//                case .diagnosis:
//                    PatientInfoDiagnosisView(
//                        store: store,
//                        icdService: icdService
//                    )
//
//                case .medication:
//                    PatientInfoMedicationView(
//                        store: store,
//                        drugService: drugService
//                    )
//                }
//            }
//        }
//    }
//}

#Preview("PatientDelegate") {
    PatientInfoFlowView(
        store: EpiLogStore(),
        onBack: { print("Back tapped") },
        onContinue: { print("Continue tapped") }
    )
}
