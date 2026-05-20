//
//  PatientInfoMedicationView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 16.12.2025.
//
import SwiftUI

struct PatientInfoMedicationView: View {

    @ObservedObject var vm: PatientMedicationViewModel

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {

                    VStack(alignment: .leading, spacing: 16) {

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Medication")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            TextField("Example: Keppra", text: $vm.medicationText, axis: .vertical)
                                .lineLimit(1...3)
                                .font(.body.weight(.semibold))
                                .textFieldStyle(.plain)
                                .autocorrectionDisabled()
                                .onChange(of: vm.medicationText) { _, newValue in
                                    vm.onMedicationChanged(newValue)
                                }

                            Divider()
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Notes / dose")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            TextField("e.g. 1000 mg bid…", text: $vm.medicationNotes, axis: .vertical)
                                .lineLimit(1...3)
                                .textFieldStyle(.plain)

                            Divider()
                        }
                    }
                    .padding(18)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground).opacity(0.9)))
                    .shadow(radius: 12, y: 6)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    if !vm.suggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Suggestions (FDA)")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            // your UI expects ICDSuggestion, so we map VM DrugSuggestion -> ICDSuggestion here
                            SuggestionScrollWithIndicator(
                                items: vm.suggestions.map { s in
                                    let title =
                                    (s.brandName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
                                    ? s.brandName!
                                    : (s.genericName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
                                    ? s.genericName!
                                    : s.displayName

                                    var parts: [String] = []
                                    if let g = s.genericName, !g.isEmpty { parts.append("generic: \(g)") }
                                    if let b = s.brandName, !b.isEmpty { parts.append("brand: \(b)") }
                                    let subtitle = parts.isEmpty ? " " : parts.joined(separator: " • ")

                                    // name = bold top line (medication name)
                                    // code = faded bottom line (generic / brand details)
                                    return ICDSuggestion(code: subtitle, name: title)
                                },
                                height: 260
                            ) { picked in
                                // picked.code is now the subtitle; match by name (med title)
                                if let match = vm.suggestions.first(where: {
                                    let brand = $0.brandName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                                    let generic = $0.genericName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                                    let title = !brand.isEmpty ? brand : (!generic.isEmpty ? generic : $0.displayName)
                                    return title == picked.name
                                }) {
                                    vm.pickSuggestion(match)
                                } else {
                                    vm.medicationText = picked.name
                                    vm.suggestions = []
                                }
                            }
                        }
                        .padding(18)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground).opacity(0.9)))
                        .shadow(radius: 12, y: 6)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
            .scrollDisabled(!vm.suggestions.isEmpty)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Medication")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .onDisappear { vm.save() }
    }
}
