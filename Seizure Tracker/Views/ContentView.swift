//
//  ContentView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 01.12.2025.
//
import FuturedArchitecture
import SwiftUI

struct ContentView: View {
    enum Screen {
        case welcome
        case patientInfo
        case tracker
    }

    enum NavDirection {
        case forward
        case backward
    }

    @State private var screen: Screen = .welcome
    @State private var navDirection: NavDirection = .forward
    @State private var patientName: String = ""

    var body: some View {
        ZStack {
            // 🔹 One shared background for all screens 
            MeshGradientView()

            // 🔹 Foreground content that slides over the same background
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
                    PatientDelegate(
                        patientName: $patientName,
                        onContinue: {
                            navDirection = .forward
                            withAnimation(.easeInOut(duration: 0.5)) {
                                screen = .tracker
                            }
                        },
                        onBack: {
                            navDirection = .backward
                            withAnimation(.easeInOut(duration: 0.5)) {
                                screen = .welcome
                            }
                        }
                    )
                    .transition(currentTransition)

                case .tracker:
                    TrackerView(
                        patientName: patientName,
                        onBack: {
                            navDirection = .backward
                            withAnimation(.easeInOut(duration: 0.5)) {
                                screen = .patientInfo
                            }
                        }
                    )
                    .transition(currentTransition)
                }
            }
        }
    }

    // MARK: - Slide direction, but background stays fixed

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
