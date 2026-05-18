//
//  PatientInfoFlowView.swift
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
                AppGradient()       // shared purple → blue gradient (Screen 1 & Screen 2)
                PatientInfoMenuView(onBack: onBack, onContinue: onContinue)
            }
            .navigationDestination(for: InfoSection.self) { section in
                ZStack {
                    AppGradient()
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
}

#Preview("PatientDelegate") {
    PatientInfoFlowView(
        store: EpiLogStore(),
        onBack: { print("Back tapped") },
        onContinue: { print("Continue tapped") }
    )
}
