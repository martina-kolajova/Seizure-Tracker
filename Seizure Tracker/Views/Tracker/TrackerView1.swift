//
//  TrackerView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 02.12.2025.
//

/*

import SwiftUI

struct TrackerView: View {
    let patientName: String
    let onBack: () -> Void

    @State private var todayCount: Int = 0
    @State private var totalCount: Int = 0
    @State private var selectedType: String = "Focal"
    @State private var note: String = ""

    enum ProfileTab: String, Identifiable {
        case personal, diagnosis, medication
        var id: String { rawValue }
    }

    @State private var activeTab: ProfileTab? = nil

    let seizureTypes = ["Focal", "Generalized", "Aura only", "Unknown"]

    var body: some View {
        NavigationStack {
            ZStack {
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

                        // Back + patient name
                        HStack {
                            Button(action: onBack) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(Circle())
                            }

                            Spacer()

                            if !patientName.isEmpty {
                                Text(patientName)
                                    .foregroundColor(.white.opacity(0.85))
                                    .font(.subheadline)
                            }
                        }
                        .padding(.top, 10)

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

                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Details for next seizure log")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.9))

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
                    // IMPORTANT: add bottom padding so last content isn't hidden under bar
                    .padding(.bottom, 80)
                }
            }
            .navigationBarHidden(true)
            .safeAreaInset(edge: .bottom) {
                ProfileBottomBar(activeTab: $activeTab)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 10)
            }
            .sheet(item: $activeTab) { tab in
                profileSheet(tab)
            }
        }
    }

    @ViewBuilder
    private func profileSheet(_ tab: ProfileTab) -> some View {
        switch tab {
        case .personal:
            ZStack {
                MeshGradientView().ignoresSafeArea()
                Form {
                    Section("Personal info") {
                        Text("Coming from profile…")
                    }
                }
                .scrollContentBackground(.hidden)
            }

        case .diagnosis:
            PatientDelegate(
                patientName: .constant(patientName),
                onContinue: { },
                onBack: { },
                initialSection: .diagnosis
            )

        case .medication:
            PatientDelegate(
                patientName: .constant(patientName),
                onContinue: { },
                onBack: { },
                initialSection: .medication
            

            )
        }
    }
}

private struct ProfileBottomBar: View {
    @Binding var activeTab: TrackerView.ProfileTab?

    var body: some View {
        HStack(spacing: 10) {
            barButton("Personal", systemImage: "heart.text.square") { activeTab = .personal }
            barButton("Diagnosis", systemImage: "waveform.path.ecg") { activeTab = .diagnosis }
            barButton("Meds", systemImage: "pills.fill") { activeTab = .medication }
        }
        .padding(10)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1))
        .shadow(color: .black.opacity(0.35), radius: 16, y: 8)
    }

    private func barButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title).font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(Color.white.opacity(0.12), in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    ContentView()
}
*/
