//
//  ContentView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 01.12.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var hasStarted = false

    var body: some View {
        if hasStarted {
            TrackerView()
        } else {
            WelcomeView {
                hasStarted = true
            }
        }
    }
}

// MARK: - First screen (white, brain icon, title)

struct WelcomeView: View {
    let onStart: () -> Void

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Brain icon + title
                VStack(spacing: 16) {
                    Image(systemName: "brain")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(Color.purple)   // or your custom violet

                    Text("Seizure Tracker")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color(red: 70/255, green: 0/255, blue: 120/255))

                    Text("A simple, personal way to log seizures.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Start button
                Button(action: onStart) {
                    Text("Get started")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 90/255, green: 0/255, blue: 150/255),
                                    Color(red: 140/255, green: 0/255, blue: 200/255)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(radius: 8, y: 4)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Second screen (violet seizure tracker)

struct TrackerView: View {
    // Simple in-memory state
    @State private var todayCount: Int = 0
    @State private var totalCount: Int = 0
    @State private var selectedType: String = "Focal"
    @State private var note: String = ""

    let seizureTypes = ["Focal", "Generalized", "Aura only", "Unknown"]

    var body: some View {
        NavigationStack {
            ZStack {
                // Darker violet gradient background
                LinearGradient(
                    colors: [
                        Color(red: 60/255, green: 0/255, blue: 110/255),
                        Color(red: 30/255, green: 0/255, blue: 70/255)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        // Header
                        VStack(spacing: 8) {
                            Text("Seizure Tracker")
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)

                            Text("Log seizures and keep a simple overview.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 10)

                        // Today card
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Today")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.9))

                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text("\(todayCount)")
                                        .font(.system(size: 56, weight: .bold))
                                        .foregroundColor(.white)

                                    Text("seizures")
                                        .foregroundColor(.white.opacity(0.8))
                                }

                                HStack(spacing: 16) {
                                    Button {
                                        if todayCount > 0 {
                                            todayCount -= 1
                                            totalCount = max(0, totalCount - 1)
                                        }
                                    } label: {
                                        Label("Undo", systemImage: "arrow.uturn.left")
                                    }

                                    Button {
                                        todayCount += 1
                                        totalCount += 1
                                    } label: {
                                        Label("Log seizure", systemImage: "plus.circle.fill")
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.white.opacity(0.9))
                                .foregroundColor(.purple)
                            }
                        }

                        // Total card
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Total logged")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.9))

                                Text("\(totalCount)")
                                    .font(.system(size: 36, weight: .semibold))
                                    .foregroundColor(.white)

                                ProgressView(value: min(Double(totalCount) / 100.0, 1.0)) {
                                    Text("Example goal: 100 logs")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .tint(.white)
                            }
                        }

                        // Details card
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Details for next seizure log")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.9))

                                // Seizure type
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Type")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))

                                    Picker("Type", selection: $selectedType) {
                                        ForEach(seizureTypes, id: \.self) { type in
                                            Text(type)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }

                                // Note
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Note (optional)")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))

                                    TextField("e.g. trigger, feeling, medication…", text: $note)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                        }

                        Text("This is just a simple personal tracker, not a medical tool.")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Reusable “glass” card with blur & rounded corners
struct GlassCard<Content: View>: View {
    let content: () -> Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.12))
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 22)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )

            content()
                .padding(18)
        }
    }
}

#Preview {
    ContentView()
}
