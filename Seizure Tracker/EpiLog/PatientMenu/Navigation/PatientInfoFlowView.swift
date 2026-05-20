//
//  PatientInfoFlowView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 16.12.2025.
//

import SwiftUI

/// Renders `AppGradient` locked to screen coordinates regardless of where
/// this view is offset. That way slot 3's background is pixel-identical to
/// slots 1 & 2 (the root `AppGradient` in ContentView) — no seam during the
/// vertical swipe, and the NavigationStack never flashes white.
private struct PinnedAppGradient: View {
    var body: some View {
        GeometryReader { geo in
            let frame = geo.frame(in: .global)
            // The slot's container is the full screen, so geo.size equals the
            // screen size. Sizing the gradient to geo.size and counter-translating
            // by the slot's global origin pins it to the same on-screen rect as
            // ContentView's root AppGradient → pixel-identical, no seam.
            AppGradient()
                .frame(width: geo.size.width, height: geo.size.height)
                .offset(x: -frame.minX, y: -frame.minY)
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

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
                PinnedAppGradient()                       // matches slots 1 & 2
                PatientInfoMenuView(onBack: onBack, onContinue: onContinue)
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationDestination(for: InfoSection.self) { section in
                ZStack {
                    AppGradient().ignoresSafeArea()
                    switch section {
                    case .personal:
                        PatientInfoPersonalView(vm: vm.makePersonalVM())
                    case .diagnosis:
                        PatientInfoDiagnosisView(vm: vm.makeDiagnosisVM())
                    case .medication:
                        PatientInfoMedicationView(vm: vm.makeMedicationVM())
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
            }
        }
        .background(AppGradient().ignoresSafeArea())
    }
}

#Preview("PatientDelegate") {
    PatientInfoFlowView(
        store: EpiLogStore(),
        onBack: { print("Back tapped") },
        onContinue: { print("Continue tapped") }
    )
}
