//
//  ContentView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 01.12.2025.
//
import SwiftUI

struct ContentView: View {
    enum TopScreen { case none, tracker }

    @State private var slot: Int = 0          // 0 splash, 1 stat1, 2 stat2, 3 patient info
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

    private var meshOpacity: Double { slot == 0 ? 1.0 : 0.0 }

    var body: some View {
        ZStack {
            // ── Fixed background (never moves) ─────────────────────────────
            AppGradient()
            MeshGradientView(frozen: isDragging)
                .ignoresSafeArea()
                .opacity(meshOpacity)
                .animation(spring, value: slot)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let canvasOffset = -CGFloat(slot) * h + dragOffset
                let maxSlot = 3

                ZStack {
                    let trackerShown = (topScreen == .tracker)

                    if topScreen == .none || trackerShown {
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
