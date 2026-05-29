//
//  ContentView.swift
//  Seizure Tracker
//
//  Pure layout. All navigation/drag state lives in AppCoordinatorViewModel.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = EpiLogStore()
    @StateObject private var vm = AppCoordinatorViewModel()

    var body: some View {
        ZStack {
            // ── Fixed background (never moves) ─────────────────────────────
            AppGradient()
            MeshGradientView(frozen: vm.isDragging)
                .ignoresSafeArea()
                .opacity(vm.meshOpacity)
                .animation(vm.spring, value: vm.slot)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                ZStack {
                    if vm.topScreen == .none || vm.trackerShown {
                        canvasStack(width: w, height: h)
                            .offset(x: vm.trackerShown ? -w : 0,
                                    y: vm.canvasOffset(slotHeight: h))
                            .gesture(
                                DragGesture()
                                    .onChanged { vm.handleDragChanged($0) }
                                    .onEnded   { vm.handleDragEnded($0) }
                            )
                            .onAppear { vm.scheduleSplashAutoAdvance() }
                    }

                    if vm.trackerShown {
                        TrackerView(
                            patientName: vm.patientDisplayName(from: store),
                            onBack: { vm.closeTracker() },
                            store: store
                        )
                        .transition(.move(edge: .trailing))
                        .zIndex(2)
                    }
                }
                .clipped()
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Vertical canvas (splash → stat1 → stat2 → patient info)
    @ViewBuilder
    private func canvasStack(width w: CGFloat, height h: CGFloat) -> some View {
        VStack(spacing: 0) {
            // Slot 0 — Splash
            WelcomeView(onStart: {})
                .frame(width: w, height: h)

            // Slot 1 — Stat page 1
            WelcomeStatPage(
                bigStat: "50 million",
                bigStatCaption: "people worldwide live with epilepsy",
                title: "You're not alone.",
                bodyText: "Epilepsy is one of the most common neurological conditions in the world — affecting tens of millions of people across every country and culture.",
                pageIndex: 0,
                totalPages: 2
            )
            .frame(width: w, height: h)

            // Slot 2 — Stat page 2
            WelcomeStatPage(
                bigStat: "70%",
                bigStatCaption: "could live seizure-free with the right treatment",
                title: "Why tracking matters",
                bodyText: "Neurologists rely on accurate seizure logs to decide whether to adjust medication. Around 50% of seizures go undocumented — often because of memory loss after the event. A consistent log gives your doctor what they need.",
                pageIndex: 1,
                totalPages: 2,
                backdropImageName: "phoneIcon"
            )
            .frame(width: w, height: h)

            // Slot 3 — Patient Info
            PatientInfoFlowView(
                store: store,
                onBack: { },
                onContinue: { vm.openTracker() }
            )
            .frame(width: w, height: h)
        }
    }
}

#Preview {
    ContentView()
}
