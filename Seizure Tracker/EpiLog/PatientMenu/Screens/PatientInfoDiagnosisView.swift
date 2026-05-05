//
//  PatientInfoDiagnosisView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 16.12.2025.
//


import SwiftUI


struct PatientInfoDiagnosisView: View {

    @ObservedObject var vm: PatientDiagnosisViewModel

    var body: some View {
        ZStack {
            MeshGradientView().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    VStack(alignment: .leading, spacing: 16) {

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Main diagnosis")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            TextField("Example: Epilepsy", text: $vm.diagnosisText, axis: .vertical)
                                .lineLimit(1...3)
                                .font(.body.weight(.semibold))
                                .textFieldStyle(.plain)
                                .autocorrectionDisabled()
                                .textSelection(.disabled)   // ⭐ FIX
                                .onChange(of: vm.diagnosisText) { _, newValue in
                                    vm.onDiagnosisChanged(newValue)
                                }


                            Divider()
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Year diagnosed")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            TextField("e.g. 2018", text: $vm.diagnosisYear)
                                .keyboardType(.numberPad)
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
                            Text("Suggestions")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            SuggestionScrollWithIndicator(
                                items: vm.suggestions,
                                height: 260
                            ) { suggestion in
                                vm.pickSuggestion(suggestion)
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
        .navigationTitle("Diagnosis")
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
        .onDisappear {
            vm.save()
        }
    }
}

