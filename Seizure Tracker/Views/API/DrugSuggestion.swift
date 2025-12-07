//
//  DrugSuggestion.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 06.12.2025.
//


import Foundation

struct DrugSuggestion: Identifiable {
    let id = UUID()
    let displayName: String      // e.g. "LEVETIRACETAM (KEPPRA)"
    let genericName: String?
    let brandName: String?
}

@MainActor
class DrugLabelService: ObservableObject {
    @Published var suggestions: [DrugSuggestion] = []

    private var searchTask: Task<Void, Never>?

    func search(term: String) {
        searchTask?.cancel()

        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            suggestions = []
            return
        }

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(250))   // debounce
            guard !Task.isCancelled else { return }
            await fetch(term: trimmed)
        }
    }

    private func fetch(term: String) async {
        var components = URLComponents(string: "https://api.fda.gov/drug/label.json")!

        // Simple search in generic OR brand name, wildcard after the term
        let q = term.lowercased()
        components.queryItems = [
            .init(
                name: "search",
                value: "openfda.generic_name:\"\(q)*\"+openfda.brand_name:\"\(q)*\""
            ),
            .init(name: "limit", value: "10")
        ]

        guard let url = components.url else { return }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            // Optional: check HTTP status
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                print("🔴 DrugLabel HTTP error:", http.statusCode)
            }

            guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("DrugLabel parsing failed: root is not a dictionary")
                suggestions = []
                return
            }

            // If the API returned an error object, log it and bail out
            if let errorInfo = root["error"] as? [String: Any] {
                print("🔴 DrugLabel API error object:", errorInfo)
                suggestions = []
                return
            }

            guard let resultsArray = root["results"] as? [[String: Any]] else {
                print("DrugLabel parsing failed: 'results' missing or wrong type")
                suggestions = []
                return
            }

            var collected: [DrugSuggestion] = []

            for item in resultsArray {
                guard let openfda = item["openfda"] as? [String: Any] else { continue }

                let generic = (openfda["generic_name"] as? [String])?.first
                let brand   = (openfda["brand_name"] as? [String])?.first

                if generic == nil && brand == nil { continue }

                let display: String
                switch (generic, brand) {
                case let (g?, b?):
                    display = "\(g.uppercased()) (\(b.uppercased()))"
                case let (g?, nil):
                    display = g.uppercased()
                case let (nil, b?):
                    display = b.uppercased()
                default:
                    continue
                }

                collected.append(
                    DrugSuggestion(
                        displayName: display,
                        genericName: generic,
                        brandName: brand
                    )
                )
            }

            print("🟢 DrugLabel: got \(collected.count) results for '\(term)'")
            suggestions = collected
        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                return // expected
            }
            print("🔴 DrugLabel API error:", error)
            suggestions = []
        }
    }
}
