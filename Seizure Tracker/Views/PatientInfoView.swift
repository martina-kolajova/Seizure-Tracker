//
//  PatientInfoView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 02.12.2025.
//


import SwiftUI
import SwiftUI

struct PatientInfoView: View {
    @Binding var patientName: String
    let onContinue: () -> Void
    let onBack: () -> Void

    // Sections for the sidebar
    enum InfoSection: String, CaseIterable, Identifiable, Hashable {
        case demographics = "Demographics"
        case personal     = "Personal info"
        case diagnosis    = "Diagnosis"
        case medication   = "Medication"
        case notes        = "Notes"

        var id: String { rawValue }
    }

    @State private var path: [InfoSection] = []

    // Local fields (can be lifted up later if you want)
    @State private var personalNotes: String = ""
    @State private var diagnosisText: String = ""
    @State private var diagnosisYear: String = ""
    @State private var seizureType: String = ""
    @State private var medicationText: String = ""
    @State private var extraNotes: String = ""

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                // Violet animated background
                MeshGradientView()
                    .ignoresSafeArea()

                // Optional: book-style image in Assets called "BookBackground"
                Image("BookBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.35)
                    .blendMode(.softLight)

                mainContent
            }
            .navigationDestination(for: InfoSection.self) { section in
                sectionDetailView(section)
            }
        }
    }

    // MARK: - Main layout

    private var mainContent: some View {
        VStack(spacing: 24) {
            // Top bar
            HStack {
                Button(action: onBack) {
                    Label("Back", systemImage: "chevron.left")
                        .foregroundColor(.white)
                }
                Spacer()
                Text("Set up patient profile")
                    .foregroundColor(.white)
                    .font(.headline)
                Spacer()
                Color.clear.frame(width: 40, height: 1)
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)

            HStack(alignment: .top, spacing: 0) {
                sidebar
                Spacer()
            }
            .padding(.top, 10)

            Spacer()

            // Small liquid button at the bottom
            HStack {
                Spacer()
                Button(action: onContinue) {
                    HStack(spacing: 8) {
                        Text("Continue to tracker")
                            .font(.headline)
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(
                        .ultraThinMaterial,
                        in: Capsule()
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .shadow(color: .black.opacity(0.4), radius: 12, y: 6)
                Spacer()
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Liquid sidebar

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(InfoSection.allCases) { section in
                NavigationLink(value: section) {
                    HStack(spacing: 10) {
                        Image(systemName: icon(for: section))
                        Text(section.rawValue)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.16))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 18)
        .padding(.trailing, 18)
        .frame(width: 240, alignment: .topLeading)
        .background(
            .ultraThinMaterial,
            in: UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 0,          // straight edge on the left
                    bottomLeading: 0,
                    bottomTrailing: 26,
                    topTrailing: 26
                )
            )
        )
        .overlay(
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 0,
                    bottomLeading: 0,
                    bottomTrailing: 26,
                    topTrailing: 26
                )
            )
            .stroke(Color.white.opacity(0.28), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 20, y: 10)
    }

    private func icon(for section: InfoSection) -> String {
        switch section {
        case .demographics: return "person.fill"
        case .personal:     return "heart.text.square"
        case .diagnosis:    return "waveform.path.ecg"
        case .medication:   return "pills.fill"
        case .notes:        return "book.closed.fill"
        }
    }

    // MARK: - Destination pages

    @ViewBuilder
    private func sectionDetailView(_ section: InfoSection) -> some View {
        switch section {
        case .demographics:
            Form {
                Section("Demographics") {
                    TextField("Patient name", text: $patientName)
                }
            }
            .navigationTitle("Demographics")

        case .personal:
            Form {
                Section("Personal info") {
                    TextField("Notes (family, living, work…)",
                              text: $personalNotes,
                              axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("Personal info")

        case .diagnosis:
            Form {
                Section("Diagnosis") {
                    TextField("Diagnosis (e.g. focal epilepsy, MTLE/HS)",
                              text: $diagnosisText)

                    TextField("Year diagnosed",
                              text: $diagnosisYear)
                        .keyboardType(.numberPad)

                    TextField("Main seizure type",
                              text: $seizureType)
                }
            }
            .navigationTitle("Diagnosis")

        case .medication:
            Form {
                Section("Medication") {
                    TextField("Medication (e.g. LEV 1000 mg bid…)",
                              text: $medicationText,
                              axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("Medication")

        case .notes:
            Form {
                Section("Extra notes") {
                    TextField("Anything else important…",
                              text: $extraNotes,
                              axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                }
            }
            .navigationTitle("Notes")
        }
    }
}
