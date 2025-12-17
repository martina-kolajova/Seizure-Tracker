//
//  TrackerView 2.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 16.12.2025.
//


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
                MeshGradientView()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.35).ignoresSafeArea())

                ScrollView {
                    VStack(spacing: 22) {

                        header

                        GlassCard {
                            todayCard
                        }

                        GlassCard {
                            totalCard
                        }

                        GlassCard {
                            detailsCard
                        }

                        footerNote
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 90) // so it doesn't sit under bottom bar
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

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 4) {
                Text(patientName.isEmpty ? "Tracker" : patientName)
                    .foregroundColor(.white.opacity(0.95))
                    .font(.headline)

                Text("Seizure log")
                    .foregroundColor(.white.opacity(0.70))
                    .font(.caption)
            }

            Spacer()

            // keeps header centered
            Color.clear.frame(width: 44, height: 44)
        }
    }

    // MARK: - Cards

    private var todayCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today")
                .font(.headline)
                .foregroundColor(.white.opacity(0.92))

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("\(todayCount)")
                    .font(.system(size: 58, weight: .bold))
                    .foregroundColor(.white)

                Text("seizures")
                    .foregroundColor(.white.opacity(0.8))
            }

            HStack(spacing: 14) {
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
            .tint(.white.opacity(0.92))
            .foregroundColor(.purple)
        }
    }

    private var totalCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Total logged")
                .font(.headline)
                .foregroundColor(.white.opacity(0.92))

            Text("\(totalCount)")
                .font(.system(size: 36, weight: .semibold))
                .foregroundColor(.white)

            ProgressView(value: min(Double(totalCount) / 100.0, 1.0)) {
                Text("Example goal: 100 logs")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.75))
            }
            .tint(.white)
        }
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Details for next seizure log")
                .font(.headline)
                .foregroundColor(.white.opacity(0.92))

            VStack(alignment: .leading, spacing: 6) {
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

            VStack(alignment: .leading, spacing: 6) {
                Text("Note (optional)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))

                TextField("e.g. trigger, feeling, medication…", text: $note)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }

    private var footerNote: some View {
        Text("This is a personal tracker and does not provide medical advice.")
            .font(.footnote)
            .foregroundColor(.white.opacity(0.65))
            .multilineTextAlignment(.center)
            .padding(.top, 6)
            .padding(.bottom, 10)
    }

    // MARK: - Sheets

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


#Preview {
    ContentView()
}
