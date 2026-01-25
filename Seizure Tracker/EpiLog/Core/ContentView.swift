//
//  ContentView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 01.12.2025.
//
import SwiftUI

struct ContentView: View {
    enum Screen { case welcome, patientInfo, tracker }
    enum NavDirection { case forward, backward }

    @State private var screen: Screen = .welcome
    @State private var navDirection: NavDirection = .forward

    // ✅ one shared store for the whole app
    @StateObject private var store = EpiLogStore()

    private var patientDisplayName: String {
        let first = store.patient.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let last  = store.patient.lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let full  = "\(first) \(last)".trimmingCharacters(in: .whitespacesAndNewlines)
        return full.isEmpty ? "Patient" : full
    }

    var body: some View {
        ZStack {
            MeshGradientView()

            ZStack {
                switch screen {
                case .welcome:
                    WelcomeView(onStart: {
                        navDirection = .forward
                        withAnimation(.easeInOut(duration: 0.5)) {
                            screen = .patientInfo
                        }
                    })
                    .transition(currentTransition)

                case .patientInfo:
                    PatientInfoFlowView(
                        store: store,
                        onBack: {
                            navDirection = .backward
                            withAnimation(.easeInOut(duration: 0.5)) {
                                screen = .welcome
                            }
                        },
                        onContinue: {
                            navDirection = .forward
                            withAnimation(.easeInOut(duration: 0.5)) {
                                screen = .tracker
                            }
                        }
                    )
                    .transition(currentTransition)

                case .tracker:
                    TrackerView(
                        patientName: patientDisplayName,
                        onBack: {
                            navDirection = .backward
                            withAnimation(.easeInOut(duration: 0.5)) {
                                screen = .patientInfo
                            }
                        }, 
                        store: store
                    )
                    .transition(currentTransition)
                }
            }
        }
    }

    private var currentTransition: AnyTransition {
        let insertionMove: AnyTransition = (navDirection == .forward)
            ? .move(edge: .trailing)
            : .move(edge: .leading)

        let removalMove: AnyTransition = (navDirection == .forward)
            ? .move(edge: .leading)
            : .move(edge: .trailing)

        return .asymmetric(
            insertion: insertionMove.combined(with: .opacity),
            removal: removalMove.combined(with: .opacity)
        )
    }
}

#Preview {
    ContentView()
}


