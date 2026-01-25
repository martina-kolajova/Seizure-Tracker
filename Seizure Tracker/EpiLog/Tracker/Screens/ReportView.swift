//
//  ReportView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 10.01.2026.
//


import SwiftUI

struct ReportView: View {
    let text: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(text.isEmpty ? "No report generated yet." : text)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.primary)                 // ✅ KEY LINE
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color(.systemBackground))            // ✅ ensures readable background
            .navigationTitle("Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: text) { Image(systemName: "square.and.arrow.up") }
                }
            }
        }
    }
}
