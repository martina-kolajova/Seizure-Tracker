
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
    
    @FocusState private var diagnosisFocused: Bool
    @State private var didPickDiagnosis: Bool = false




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

                        // Suggestions card
                        if !icdService.suggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Suggestions")
                                    .font(.headline)
                                    .foregroundColor(.secondary)

                                // ✅ Scrollable list with a visible right-side indicator
                                SuggestionScrollWithIndicator(
                                    items: icdService.suggestions,
                                    height: 260
                                ) { suggestion in
                                    diagnosisText = "\(suggestion.code) – \(suggestion.name)"
                                    icdService.suggestions = []
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
                // ✅ Disable the OUTER scroll when suggestions are visible,
                // so your finger drag scrolls the suggestions list.
                .scrollDisabled(!icdService.suggestions.isEmpty)
               

            }
            .navigationTitle("Diagnosis")

        case .medication:
            ZStack {
                MeshGradientView()
                    .overlay(Color.black.opacity(0.40))
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // MARK: Medication card (same as Diagnosis card style)
                        VStack(alignment: .leading, spacing: 16) {

                            // Main medication field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Medication")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                TextField(
                                    "Start typing medication…",
                                    text: $medicationText,
                                    axis: .vertical
                                )
                                .lineLimit(1...3)
                                .font(.body.weight(.semibold))
                                .textFieldStyle(.plain)
                                .autocorrectionDisabled()
                                .onChange(of: medicationText) { _, newValue in
                                    drugService.search(term: newValue)
                                }

                                Divider()
                            }

                            // Optional notes (keep if you want)
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Notes / dose")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                TextField(
                                    "e.g. 1000 mg bid…",
                                    text: $extraNotes,
                                    axis: .vertical
                                )
                                .lineLimit(1...3)
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

                        // MARK: Suggestions card (same idea as Diagnosis)
                        if !drugService.suggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Suggestions (FDA)")
                                    .font(.headline)
                                    .foregroundColor(.secondary)

                                SuggestionScrollWithIndicator(
                                    items: drugService.suggestions.map { s in
                                        // Prefer "human" names first
                                        let title = (s.brandName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
                                            ? s.brandName!
                                            : (s.genericName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
                                                ? s.genericName!
                                                : s.displayName

                                        var parts: [String] = []
                                        if let g = s.genericName, !g.isEmpty { parts.append("generic: \(g)") }
                                        if let b = s.brandName, !b.isEmpty { parts.append("brand: \(b)") }
                                        let subtitle = parts.isEmpty ? " " : parts.joined(separator: " • ")

                                        return ICDSuggestion(code: title, name: subtitle)
                                    },
                                    height: 260
                                ) { picked in
                                    // Fill the text field with the chosen med name (NOT the ingredients)
                                    medicationText = picked.code
                                    drugService.suggestions = []
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
                // ✅ Same behavior as Diagnosis: when suggestions exist,
                // lock the OUTER scroll so the inner list scrolls naturally.
                .scrollDisabled(!drugService.suggestions.isEmpty)
            }
            .navigationTitle("Medication")

        }
    }
}

private struct SuggestionScrollWithIndicator: View {
    let items: [ICDSuggestion]
    let height: CGFloat
    let onSelect: (ICDSuggestion) -> Void

    @State private var contentHeight: CGFloat = 1
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .topTrailing) {

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ✅ Offset sentinel (tracks scroll position reliably)
                    GeometryReader { geo in
                        Color.clear
                            .preference(
                                key: ScrollOffsetKey.self,
                                value: -geo.frame(in: .named("suggestions")).minY
                            )
                    }
                    .frame(height: 0)

                    ForEach(items) { suggestion in
                        Button {
                            onSelect(suggestion)
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
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Divider()
                    }
                }
                // ✅ measure total content height
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear { contentHeight = max(geo.size.height, 1) }
                            .onChange(of: geo.size.height) { _, newValue in
                                contentHeight = max(newValue, 1)
                            }
                    }
                )
            }
            .coordinateSpace(name: "suggestions")
            .onPreferenceChange(ScrollOffsetKey.self) { offset in
                scrollOffset = offset
            }
            .frame(height: height)

            // Custom indicator (track + thumb)
            if contentHeight > height {
                let trackH = height
                let thumbH = max(24, trackH * (height / contentHeight))
                let maxOffset = max(contentHeight - height, 1)
                let progress = min(max(scrollOffset / maxOffset, 0), 1)
                let thumbY = (trackH - thumbH) * progress

                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.primary.opacity(0.10))
                        .frame(width: 4, height: trackH)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.primary.opacity(0.35))
                        .frame(width: 4, height: thumbH)
                        .offset(y: thumbY)
                }
                .padding(.trailing, 2)
                .allowsHitTesting(false)
            }
        }
    }
}


private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}



#Preview {
    PatientInfoView(
        patientName: .constant("Anna Preview"),  // any test name
        onContinue: { },
        onBack: { }
    )
}


