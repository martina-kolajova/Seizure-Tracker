//
//  ContentView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 01.12.2025.
//
import SwiftUI

struct ContentView: View {
    // top-level screen layered on top of the canvas
    enum TopScreen { case none, tracker }

    @State private var slot: Int = 0          // 0 = welcome, 1 = home, 2 = patientInfo
    @State private var dragOffset: CGFloat = 0
    @State private var topScreen: TopScreen = .none
    @State private var isDragging: Bool = false

    @StateObject private var store = EpiLogStore()

    private let spring: Animation = .spring(response: 0.5, dampingFraction: 0.86)

    private var patientDisplayName: String {
        let first = store.patient.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let last  = store.patient.lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let full  = "\(first) \(last)".trimmingCharacters(in: .whitespacesAndNewlines)
        return full.isEmpty ? "Patient" : full
    }

    var body: some View {
        ZStack {
            // ── Truly fixed background — never moves ──────────────────────
            MeshGradientView(frozen: isDragging).ignoresSafeArea()

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let canvasOffset = -CGFloat(slot) * h + dragOffset
                let maxSlot = 4

                ZStack {
                    let trackerShown = (topScreen == .tracker)

                    // The vertical canvas — slides LEFT off-screen when tracker is shown
                    if topScreen == .none || trackerShown {
                        VStack(spacing: 0) {
                            // Slot 0 — Splash (EpiLog logo + tagline). Auto-advances.
                            WelcomeView(onStart: {})
                                .frame(width: w, height: h)

                            // Slot 1 — Stat page 1 (50M / "You're not alone")
                            WelcomeStatPage(
                                bigStat: "50 million",
                                bigStatCaption: "people worldwide live with epilepsy",
                                title: "You're not alone.",
                                bodyText: "Epilepsy is one of the most common neurological conditions in the world — affecting tens of millions of people across every country and culture.",
                                pageIndex: 0,
                                totalPages: 3
                            )
                            .frame(width: w, height: h)

                            // Slot 2 — Stat page 2 (70% / Why tracking matters)
                            WelcomeStatPage(
                                bigStat: "70%",
                                bigStatCaption: "could live seizure-free with the right treatment",
                                title: "Why tracking matters",
                                bodyText: "Neurologists rely on accurate seizure logs to decide whether to adjust medication. Around 50% of seizures go undocumented — often because of memory loss after the event. A consistent log gives your doctor what they need.",
                                pageIndex: 1,
                                totalPages: 3,
                                backdropImageName: "phoneIcon"
                            )
                            .frame(width: w, height: h)

                            // Slot 3 — Stat page 3 (Built for clarity)
                            WelcomeStatPage(
                                bigStat: "EpiLog",
                                bigStatCaption: "your personal seizure diary",
                                title: "Built for clarity",
                                bodyText: "Log events in seconds. Track triggers, mood, sleep and medication. Spot patterns over time and share them with your clinician.",
                                pageIndex: 2,
                                totalPages: 3,
                                backdropImageName: "phoneIcon"
                            )
                            .frame(width: w, height: h)

                            // Slot 4 — Patient Info
                            PatientInfoFlowView(
                                store: store,
                                onBack: { },
                                onContinue: {
                                    withAnimation(spring) { topScreen = .tracker }
                                }
                            )
                            .frame(width: w, height: h)
                        }
                        .offset(x: trackerShown ? -w : 0, y: canvasOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { v in
                                    isDragging = true
                                    let drag = v.translation.height
                                    // rubber-band at top and bottom
                                    if (slot == 0 && drag > 0) || (slot == maxSlot && drag < 0) {
                                        dragOffset = drag * 0.08
                                    } else {
                                        dragOffset = drag
                                    }
                                }
                                .onEnded { v in
                                    isDragging = false
                                    let vel = v.predictedEndTranslation.height
                                    let up   = v.translation.height < -60 || vel < -300
                                    let down = v.translation.height >  60 || vel >  300
                                    if up {
                                        withAnimation(spring) {
                                            slot = min(slot + 1, maxSlot)
                                            dragOffset = 0
                                        }
                                    } else if down {
                                        withAnimation(spring) {
                                            slot = max(slot - 1, 0)
                                            dragOffset = 0
                                        }
                                    } else {
                                        withAnimation(spring) { dragOffset = 0 }
                                    }
                                }
                        )
                        .onAppear {
                            // Auto-advance from splash to the first stat page
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                                if slot == 0 { withAnimation(spring) { slot = 1 } }
                            }
                        }
                    }

                    if trackerShown {
                        TrackerView(
                            patientName: patientDisplayName,
                            onBack: { withAnimation(spring) { topScreen = .none } },
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
}

#Preview {
    ContentView()
}
