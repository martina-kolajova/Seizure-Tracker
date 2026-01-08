//
//  DrugSuggestion.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 06.12.2025.

import Foundation
import Combine


struct DrugSuggestion: Identifiable {
    let id = UUID()
    let displayName: String
    let genericName: String?
    let brandName: String?
}

// MARK: - Codable models for FDA

private struct FDADrugResponse: Decodable {
    let results: [FDADrugItem]?
    let error: FDAErrorBody?
}

private struct FDADrugItem: Decodable {
    let brandName: String?
    let genericName: String?

    enum CodingKeys: String, CodingKey {
        case brandName = "brand_name"
        case genericName = "generic_name"
    }
}

private struct FDAErrorBody: Decodable {
    let message: String?
}

@MainActor
final class DrugLabelService: ObservableObject {
    @Published var suggestions: [DrugSuggestion] = []

    private var searchTask: Task<Void, Never>?

    private let session: URLSession
    private let debounce: Duration
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared, debounce: Duration = .milliseconds(250)) {
        self.session = session
        self.debounce = debounce
    }

    func search(term: String) {
        searchTask?.cancel()

        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            suggestions = []
            return
        }

        searchTask = Task {
            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled else { return }
            await fetch(term: trimmed)
        }
    }

    func fetch(term: String) async {
        let q = term.lowercased()

        var components = URLComponents(string: "https://api.fda.gov/drug/ndc.json")!
        components.queryItems = [
            .init(name: "search", value: "brand_name:\(q)* OR generic_name:\(q)*"),
            .init(name: "limit", value: "25")
        ]

        guard let url = components.url else { return }

        do {
            let (data, _) = try await session.data(from: url)

            // Decoding, no manual parsing
            let decoded = try decoder.decode(FDADrugResponse.self, from: data)

            // FDA error payload => empty
            if decoded.error != nil {
                suggestions = []
                return
            }

            let mapped = (decoded.results ?? []).compactMap { item -> DrugSuggestion? in
                let brand = item.brandName
                let generic = item.genericName
                if brand == nil && generic == nil { return nil }

                let display: String
                switch (generic, brand) {
                case let (g?, b?):
                    display = "\(b) • \(g)"
                case let (g?, nil):
                    display = g
                case let (nil, b?):
                    display = b
                default:
                    return nil
                }

                return DrugSuggestion(displayName: display, genericName: generic, brandName: brand)
            }

            // Dedupe by (generic, brand)
            var seen = Set<String>()
            let unique = mapped.filter { s in
                let key = "\(s.genericName?.lowercased() ?? "")|\(s.brandName?.lowercased() ?? "")"
                return seen.insert(key).inserted
            }

            // Sort: brand prefix first
            let sorted = unique.sorted {
                let aPref = ($0.brandName?.lowercased().hasPrefix(q) ?? false)
                let bPref = ($1.brandName?.lowercased().hasPrefix(q) ?? false)
                if aPref != bPref { return aPref && !bPref }
                return ($0.brandName ?? $0.genericName ?? "") < ($1.brandName ?? $1.genericName ?? "")
            }

            suggestions = sorted

        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled { return }
            suggestions = []
        }
    }
}





//struct DrugSuggestion: Identifiable {
//    let id = UUID()
//    let displayName: String      // e.g. "LEVETIRACETAM (KEPPRA)"
//    let genericName: String?
//    let brandName: String?
//}
//
//@MainActor
//class DrugLabelService: ObservableObject {
//    @Published var suggestions: [DrugSuggestion] = []
//
//    private var searchTask: Task<Void, Never>?
//
//    private let session: URLSession
//    private let debounce: Duration
//
//    init(session: URLSession = .shared, debounce: Duration = .milliseconds(250)) {
//        self.session = session
//        self.debounce = debounce
//    }
//
//    func search(term: String) {
//        searchTask?.cancel()
//
//        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard trimmed.count >= 2 else {
//            suggestions = []
//            return
//        }
//
//        searchTask = Task {
//            try? await Task.sleep(for: debounce) // debounce
//            guard !Task.isCancelled else { return }
//            await fetch(term: trimmed)
//        }
//    }
//
//    // ⬇️ Make this internal (default) instead of private so tests can call it via @testable import.
//    func fetch(term: String) async {
//        var components = URLComponents(string: "https://api.fda.gov/drug/ndc.json")!
//
//        let q = term.lowercased()
//        components.queryItems = [
//            .init(name: "search", value: "brand_name:\(q)* OR generic_name:\(q)*"),
//            .init(name: "limit", value: "25")
//        ]
//
//        guard let url = components.url else { return }
//
//        do {
//            let (data, response) = try await session.data(from: url)
//
//            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
//                // not fatal for autocomplete typing
//            }
//
//            guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
//                suggestions = []
//                return
//            }
//
//            if root["error"] != nil {
//                suggestions = []
//                return
//            }
//
//            guard let resultsArray = root["results"] as? [[String: Any]] else {
//                suggestions = []
//                return
//            }
//
//            var collected: [DrugSuggestion] = []
//            for item in resultsArray {
//                let brand   = item["brand_name"] as? String
//                let generic = item["generic_name"] as? String
//                if brand == nil && generic == nil { continue }
//
//                let display: String
//                switch (generic, brand) {
//                case let (g?, b?):
//                    display = "\(b) • \(g)"
//                case let (g?, nil):
//                    display = g
//                case let (nil, b?):
//                    display = b
//                default:
//                    continue
//                }
//
//                collected.append(.init(displayName: display, genericName: generic, brandName: brand))
//            }
//
//            // Dedupe by (generic, brand)
//            var seen = Set<String>()
//            let unique = collected.filter { s in
//                let key = "\(s.genericName?.lowercased() ?? "")|\(s.brandName?.lowercased() ?? "")"
//                return seen.insert(key).inserted
//            }
//
//            // Sort: brand prefix first
//            let lowerTerm = term.lowercased()
//            let sorted = unique.sorted {
//                let aPref = ($0.brandName?.lowercased().hasPrefix(lowerTerm) ?? false)
//                let bPref = ($1.brandName?.lowercased().hasPrefix(lowerTerm) ?? false)
//                if aPref != bPref { return aPref && !bPref }
//                return ($0.brandName ?? $0.genericName ?? "") < ($1.brandName ?? $1.genericName ?? "")
//            }
//
//            suggestions = sorted
//        } catch {
//            if let urlError = error as? URLError, urlError.code == .cancelled { return }
//            suggestions = []
//        }
//    }
//}
//
