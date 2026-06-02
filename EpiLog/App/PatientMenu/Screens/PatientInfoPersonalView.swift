//
//  PatientInfoPersonalView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 16.12.2025.
//

import SwiftUI

struct PatientInfoPersonalView: View {

    @ObservedObject var vm: PatientPersonalViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                basicInfoCard
                notesCard
                Spacer(minLength: 40)
            }
            .padding(.top, 8)
        }
        .background(Color.clear)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Personal info")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.purple.opacity(0.5), in: Circle())
                }
            }
        }
        .onDisappear { vm.save() }
    }

    // MARK: - Card 1: basic info

    private var basicInfoCard: some View {
        VStack(spacing: 0) {
            labeledField("First name", placeholder: "e.g. Anna", text: $vm.firstName)
            divider
            labeledField("Last name", placeholder: "e.g. Novak", text: $vm.lastName)

            // Section title
            HStack {
                Text("Basic info")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "#888888"))
                Spacer()
            }
            .padding(.top, 12)

            // 3-column row
            HStack(spacing: 12) {
                miniField(label: "Age",          text: $vm.ageText,      placeholder: "27")
                miniField(label: heightLabel,    text: $vm.heightValue,  placeholder: vm.heightUnit == .cm ? "165" : "5'7\"")
                miniField(label: weightLabel,    text: $vm.weightValue,  placeholder: vm.weightUnit == .kg ? "60" : "132")
            }
            .padding(.top, 6)

            // Unit pill toggles
            HStack(spacing: 8) {
                unitPill("cm",   active: vm.heightUnit == .cm)   { vm.heightUnit = .cm }
                unitPill("ft/in",active: vm.heightUnit == .ftIn) { vm.heightUnit = .ftIn }
                Spacer().frame(width: 6)
                unitPill("kg",   active: vm.weightUnit == .kg)   { vm.weightUnit = .kg }
                unitPill("lb",   active: vm.weightUnit == .lb)   { vm.weightUnit = .lb }
                Spacer()
            }
            .padding(.top, 10)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.88))
        )
        .padding(.horizontal, 14)
    }

    private var heightLabel: String { "Height (\(vm.heightUnit == .cm ? "cm" : "ft/in"))" }
    private var weightLabel: String { "Weight (\(vm.weightUnit == .kg ? "kg" : "lb"))" }

    // MARK: - Card 2: notes

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Additional notes")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "#555555"))

            ZStack(alignment: .topLeading) {
                if vm.personalNotes.isEmpty {
                    Text("Family, work, living situation…")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
                TextEditor(text: $vm.personalNotes)
                    .font(.system(size: 13))
                    .frame(minHeight: 90)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.70))
        )
        .padding(.horizontal, 14)
        .padding(.top, 10)
    }

    // MARK: - Reusable bits

    private var divider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.25))
            .frame(height: 0.5)
            .padding(.vertical, 8)
    }

    @ViewBuilder
    private func labeledField(_ title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "#888888"))
            TextField(placeholder, text: text)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#BBBBBB"))
                .textFieldStyle(.plain)
        }
    }

    @ViewBuilder
    private func miniField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "#888888"))
            TextField(placeholder, text: text)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#BBBBBB"))
                .keyboardType(.numbersAndPunctuation)
                .textFieldStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func unitPill(_ label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: active ? .semibold : .regular))
                .foregroundColor(active ? Color(hex: "#555555") : Color(hex: "#888888"))
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(active ? Color.white : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }
}
