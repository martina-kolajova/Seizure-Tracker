//
//  ContentView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 01.12.2025.
//
import SwiftUI

struct ContentView: View {
    enum Screen { case welcome, home, patientInfo, tracker }
    enum NavDirection { case forward, backward }

    @State private var screen: Screen = .welcome
    @State private var navDirection: NavDirection = .forward

    //  one shared store for the whole app
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
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                            screen = .home
                        }
                    })
                    .transition(currentTransition)

                case .home:
                    HomeView(onContinue: {
                        navDirection = .forward
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                            screen = .patientInfo
                        }
                    })
                    .transition(currentTransition)

                case .patientInfo:
                    PatientInfoFlowView(
                        store: store,
                        onBack: {
                            navDirection = .backward
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                                screen = .welcome
                            }
                        },
                        onContinue: {
                            navDirection = .forward
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
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
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                                screen = .patientInfo
                            }
                        }, 
                        store: store
                    )
                    .transition(currentTransition)
                }
            }
            .clipped()
        }
    }

    private var currentTransition: AnyTransition {
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let insertX: CGFloat =  navDirection == .forward ?  screenWidth : -screenWidth
        let removeX: CGFloat =  navDirection == .forward ? -screenWidth :  screenWidth
        return .asymmetric(
            insertion: .offset(x: insertX),
            removal:   .offset(x: removeX)
        )
    }
}

#Preview {
    ContentView()
}


