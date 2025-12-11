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
        //case demographics = "Demographics"
        case personal     = "Personal info"
        case diagnosis    = "Diagnosis"
        case medication   = "Medication"
       // case notes        = "Notes"

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
                        // Circle center fixed slightly off the LEFT edge
                        let circleCenter = CGPoint(
                            x: -geo.size.width * 0.10,
                            y: geo.size.height * 0.5
                        )

                        // Logo (half visible on the left)
                        Image("logo-white")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white.opacity(0.7))
                            .scaledToFit()
                            .frame(width: geo.size.height * 2)
                            .position(circleCenter)
                            .allowsHitTesting(false)

                        let totalSections = InfoSection.allCases.count
                        let radius = geo.size.height * 0.36

                        // Same angles as before: right half-arc
                        let startAngle = -60.0 * .pi / 180.0
                        let endAngle   =  60.0 * .pi / 180.0
                        let angleStep  = totalSections > 1
                            ? (endAngle - startAngle) / Double(totalSections - 1)
                            : 0

                        // 👉 constant shift of all buttons to the right
                        let buttonOffsetX = geo.size.width * 0.22   // tweak this 0.22

                        ForEach(Array(InfoSection.allCases.enumerated()), id: \.1) { index, section in
                            let angle = startAngle + Double(index) * angleStep

                            let baseX = circleCenter.x + cos(angle) * radius
                            let baseY = circleCenter.y + sin(angle) * radius

                            let x = baseX + buttonOffsetX
                            let y = baseY

                            NavigationLink(value: section) {
                                sectionPill(for: section)
                            }
                            .buttonStyle(.plain)
                            .position(x: x, y: y)
                        }
                    }
                }
                .frame(width: 260)

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
        //case .demographics: return "person.fill"
        case .personal:     return "heart.text.square"
        case .diagnosis:    return "waveform.path.ecg"
        case .medication:   return "pills.fill"
       // case .notes:        return "book.closed.fill"
        }
    }

    // MARK: - Destination pages

    @ViewBuilder
    private func sectionDetailView(_ section: InfoSection) -> some View {
        switch section {
    

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
            ZStack {
                MeshGradientView()
                    .overlay(Color.black.opacity(0.40))
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // MARK: Diagnosis card
                        VStack(alignment: .leading, spacing: 16) {

                            // ⬇️ removed the "Diagnosis" title + debug text

                            // Main diagnosis field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Main diagnosis")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                TextField(
                                    "Start typing diagnosis…",
                                    text: $diagnosisText,
                                    axis: .vertical      // multi-line
                                )
                                .lineLimit(1...3)
                                .font(.body.weight(.semibold))
                                .textFieldStyle(.plain)
                                .autocorrectionDisabled()
                                .onChange(of: diagnosisText) { newValue in
                                    print("DEBUG: onChange fired, new diagnosisText =", newValue)
                                    icdService.search(term: newValue)
                                }

                                Divider()
                            }

                            // Year field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Year diagnosed")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                TextField("e.g. 2018", text: $diagnosisYear)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.plain)

                                Divider()
                            }
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color(.systemBackground).opacity(0.9))
                        )
                        .shadow(radius: 12, y: 6)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                        // Suggestions card stays the same...
                        if !icdService.suggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Suggestions")
                                    .font(.headline)
                                    .foregroundColor(.secondary)

                                ForEach(icdService.suggestions) { suggestion in
                                    Button {
                                        diagnosisText = "\(suggestion.code) – \(suggestion.name)"
                                        icdService.suggestions = []
                                    } label: {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(suggestion.code)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundColor(.primary)
                                            Text(suggestion.name)
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 6)
                                    }
                                    .buttonStyle(.plain)

                                    Divider()
                                }
                            }
                            .padding(18)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color(.systemBackground).opacity(0.9))
                            )
                            .shadow(radius: 12, y: 6)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
            .navigationTitle("Diagnosis")


        case .medication:
            ZStack {
                MeshGradientView()
                    .ignoresSafeArea()
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
                .scrollContentBackground(.hidden)   // let the mesh show through
                        .background(Color.clear)
                    }
            .navigationTitle("Medication")
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


