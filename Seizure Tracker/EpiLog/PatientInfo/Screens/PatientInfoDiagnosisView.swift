//
//  PatientInfoDiagnosisView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 16.12.2025.
//


import SwiftUI


struct PatientInfoDiagnosisView: View {

    @ObservedObject var store: EpiLogStore
    @ObservedObject var icdService: ICD10Service

    var body: some View {
        ZStack {
            MeshGradientView()
                .overlay(Color.black.opacity(0.25))
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    VStack(alignment: .leading, spacing: 16) {

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Main diagnosis")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            TextField("Start typing diagnosis…", text: $store.patient.diagnosisText, axis: .vertical)
                                .lineLimit(1...3)
                                .font(.body.weight(.semibold))
                                .textFieldStyle(.plain)
                                .autocorrectionDisabled()
                                .onChange(of: store.patient.diagnosisText) { newValue in
                                    icdService.search(term: newValue)
                                }

                            Divider()
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Year diagnosed")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            TextField("e.g. 2018", text: $store.patient.diagnosisYear)
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

                    if !icdService.suggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Suggestions")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            SuggestionScrollWithIndicator(
                                items: icdService.suggestions,
                                height: 260
                            ) { suggestion in
                                store.patient.diagnosisText = "\(suggestion.code) – \(suggestion.name)"
                                icdService.suggestions = []
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
            .scrollDisabled(!icdService.suggestions.isEmpty)
        }
        .navigationTitle("Diagnosis")
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
    }
}


//
//struct PatientInfoDiagnosisView: View {
//    @Binding var diagnosisText: String
//    @Binding var diagnosisYear: String
//
//    @ObservedObject var icdService: ICD10Service
//
//    var body: some View {
//        ZStack {
//            MeshGradientView()
//                .overlay(Color.black.opacity(0.25))
//                .ignoresSafeArea()
//
//            ScrollView {
//                VStack(spacing: 20) {
//
//                    VStack(alignment: .leading, spacing: 16) {
//
//                        VStack(alignment: .leading, spacing: 6) {
//                            Text("Main diagnosis")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//
//                            TextField("Start typing diagnosis…", text: $diagnosisText, axis: .vertical)
//                                .lineLimit(1...3)
//                                .font(.body.weight(.semibold))
//                                .textFieldStyle(.plain)
//                                .autocorrectionDisabled()
//                                .onChange(of: diagnosisText) { newValue in
//                                    icdService.search(term: newValue)
//                                }
//
//                            Divider()
//                        }
//
//                        VStack(alignment: .leading, spacing: 6) {
//                            Text("Year diagnosed")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//
//                            TextField("e.g. 2018", text: $diagnosisYear)
//                                .keyboardType(.numberPad)
//                                .textFieldStyle(.plain)
//
//                            Divider()
//                        }
//                    }
//                    .padding(18)
//                    .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground).opacity(0.9)))
//                    .shadow(radius: 12, y: 6)
//                    .padding(.horizontal, 20)
//                    .padding(.top, 16)
//
//                    if !icdService.suggestions.isEmpty {
//                        VStack(alignment: .leading, spacing: 10) {
//                            Text("Suggestions")
//                                .font(.headline)
//                                .foregroundColor(.secondary)
//
//                            SuggestionScrollWithIndicator(
//                                items: icdService.suggestions,
//                                height: 260
//                            ) { suggestion in
//                                diagnosisText = "\(suggestion.code) – \(suggestion.name)"
//                                icdService.suggestions = []
//                            }
//                        }
//                        .padding(18)
//                        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground).opacity(0.9)))
//                        .shadow(radius: 12, y: 6)
//                        .padding(.horizontal, 20)
//                        .padding(.bottom, 24)
//                    }
//                }
//            }
//            .scrollDisabled(!icdService.suggestions.isEmpty)
//        }
//        .navigationTitle("Diagnosis")
//        .toolbarBackground(.visible, for: .navigationBar)
//        .toolbarColorScheme(.dark, for: .navigationBar)
//        .tint(.white) 
//    }
//}
