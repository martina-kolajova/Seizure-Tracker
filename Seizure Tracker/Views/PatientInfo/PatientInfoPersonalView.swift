//
//  PatientInfoPersonalView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 16.12.2025.
//


import SwiftUI

struct PatientInfoPersonalView: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var ageText: String
    @Binding var heightValue: String
    @Binding var weightValue: String
    @Binding var heightUnit: HeightUnit
    @Binding var weightUnit: WeightUnit
    @Binding var personalNotes: String

    var body: some View {
        ZStack {
            MeshGradientView()
                .overlay(Color.black.opacity(0.25))
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    VStack(alignment: .leading, spacing: 16) {

                        labeledField("First name", placeholder: "e.g. Anna", text: $firstName)
                        labeledField("Last name", placeholder: "e.g. Novak", text: $lastName)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Basic info")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HStack(spacing: 16) {
                                miniNumberField("Age", placeholder: "27", text: $ageText)

                                miniNumberField(
                                    "Height (\(heightUnit == .cm ? "cm" : "ft/in"))",
                                    placeholder: heightUnit == .cm ? "165" : "5'7\"",
                                    text: $heightValue
                                )

                                miniNumberField(
                                    "Weight (\(weightUnit == .kg ? "kg" : "lb"))",
                                    placeholder: weightUnit == .kg ? "60" : "132",
                                    text: $weightValue
                                )
                            }

                            // If you want unit pickers visible right here:
                            HStack(spacing: 12) {
                                Picker("Height", selection: $heightUnit) {
                                    ForEach(HeightUnit.allCases, id: \.self) { Text($0.rawValue) }
                                }
                                .pickerStyle(.segmented)

                                Picker("Weight", selection: $weightUnit) {
                                    ForEach(WeightUnit.allCases, id: \.self) { Text($0.rawValue) }
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding(.top, 6)
                        }
                    }
                    .padding(18)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground).opacity(0.9)))
                    .shadow(radius: 12, y: 6)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Additional notes")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        TextField("Family, work, living situation…", text: $personalNotes, axis: .vertical)
                            .lineLimit(3...6)
                            .textFieldStyle(.plain)

                        Divider()
                    }
                    .padding(18)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground).opacity(0.9)))
                    .shadow(radius: 12, y: 6)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Personal info")
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white) 
      
    }

    @ViewBuilder
    private func labeledField(_ title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundColor(.secondary)
            TextField(placeholder, text: text).textFieldStyle(.plain)
            Divider()
        }
    }

    @ViewBuilder
    private func miniNumberField(_ title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption2).foregroundColor(.secondary)
            TextField(placeholder, text: text)
                .keyboardType(.numbersAndPunctuation)
                .textFieldStyle(.plain)
            Divider()
        }
    }
}
