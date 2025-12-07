//
//  PatientInfoView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 02.12.2025.
//

//  PatientInfoView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 02.12.2025.
//

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
    @State private var medicationText: String = ""
    @State private var extraNotes: String = ""
    
    @StateObject private var icdService = ICD10Service()
    @StateObject private var drugService = DrugLabelService()



    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                // Violet animated background
                MeshGradientView()
                    .ignoresSafeArea()

                mainContent
            }
            .navigationDestination(for: InfoSection.self) { section in
                sectionDetailView(section)
            }
        }
    }

    // MARK: - Main layout
    // MARK: - Radial menu helpers

    private func angleForIndex(_ index: Int, total: Int) -> CGFloat {
        // Angles in radians along a left-side arc (from top-left to bottom-left)
        // tweak these to taste
        let start = -CGFloat.pi * 0.65  // around -117°
        let end   =  CGFloat.pi * 0.65  // around  117°

        if total <= 1 { return 0 }
        let t = CGFloat(index) / CGFloat(total - 1)
        return start + (end - start) * t
    }

    private func sectionPill(for section: InfoSection) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon(for: section))
            Text(section.rawValue)
                .font(.subheadline)
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 10, y: 6)
    }


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
                Color.clear.frame(width: 60, height: 3)
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)

            HStack {
                GeometryReader { geo in
                    ZStack {
                        // BIG BACKGROUND LOGO (half visible on the left)
                        Image("logo-white")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white.opacity(0.7))
                            .scaledToFit()
                            .frame(width: geo.size.height * 0.9)
                            .position(
                                x: -geo.size.width * 0.15,   // push off-screen to the left
                                y: geo.size.height * 0.4
                            )
                            .allowsHitTesting(false)

                        // RADIAL BUTTONS AROUND THE LOGO
                        ForEach(Array(InfoSection.allCases.enumerated()), id: \.1) { index, section in
                            let angle = angleForIndex(index, total: InfoSection.allCases.count)
                            let radius = geo.size.height * 0.32
                            let center = CGPoint(x: geo.size.width * 0.18,
                                                 y: geo.size.height * 0.4)

                            let x = center.x + cos(angle) * radius
                            let y = center.y + sin(angle) * radius

                            NavigationLink(value: section) {
                                sectionPill(for: section)
                            }
                            .buttonStyle(.plain)
                            .position(x: x, y: y)
                        }
                    }
                }
                .frame(width: 260)   // left column width

                Spacer()
            }
            .padding(.top, 10)
            .padding(.leading, 8)


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
        .padding(.trailing, 40)
        .frame(width: 210, alignment: .topLeading)
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

                    // DEBUG – so we know this view is really shown
                    Text("Diagnosis view loaded")
                        .foregroundColor(.secondary)
                        .onAppear {
                            print("DEBUG: Diagnosis view appeared")
                        }

                    TextField("Start typing diagnosis…", text: $diagnosisText)
                        .autocorrectionDisabled()
                        .onAppear {
                            print("DEBUG: Diagnosis TextField appeared")
                        }
                        .onChange(of: diagnosisText) { newValue in
                            print("DEBUG: onChange fired, new diagnosisText =", newValue)
                            icdService.search(term: newValue)
                        }

                    //Text("Echo: \(diagnosisText)")
                    //    .foregroundColor(.secondary)

                    TextField("Year diagnosed", text: $diagnosisYear)
                        .keyboardType(.numberPad)
                }

                if !icdService.suggestions.isEmpty {
                    Section("Suggestions") {
                        ForEach(icdService.suggestions) { suggestion in
                            Button {
                                diagnosisText = "\(suggestion.code) – \(suggestion.name)"
                                icdService.suggestions = []
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.code)
                                        .font(.headline)
                                    Text(suggestion.name)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Diagnosis")

        case .medication:
            Form {
                Section("Medication") {
                    TextField("Start typing medication…", text: $medicationText)
                        .autocorrectionDisabled()
                        .onChange(of: medicationText) { oldValue, newValue in
                            drugService.search(term: newValue)
                        }

                    // You can keep extra free-text notes here if you like:
                    // TextField("Notes / dose (e.g. 1000 mg bid…)",
                    //           text: $extraNotesForMeds,
                    //           axis: .vertical)
                    //     .lineLimit(3, reservesSpace: true)
                }

                if !drugService.suggestions.isEmpty {
                    Section("Suggestions (FDA)") {
                        ForEach(drugService.suggestions) { suggestion in
                            Button {
                                // Fill main field with the formatted name
                                medicationText = suggestion.displayName
                                drugService.suggestions = []
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.displayName)
                                        .font(.headline)

                                    if let g = suggestion.genericName,
                                       let b = suggestion.brandName {
                                        Text("generic: \(g), brand: \(b)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else if let g = suggestion.genericName {
                                        Text("generic: \(g)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else if let b = suggestion.brandName {
                                        Text("brand: \(b)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
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

#Preview {
    PatientInfoView(
        patientName: .constant("Anna Preview"),  // any test name
        onContinue: { },
        onBack: { }
    )
}


