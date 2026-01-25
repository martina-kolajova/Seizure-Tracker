//
//  ICDCode.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 04.12.2025.
//
import Foundation
import SwiftUI

/// Model representing one ICD-10 autocomplete suggestion
/// (e.g. "A00.0 – Cholera due to Vibrio cholerae")
struct ICDSuggestion: Identifiable, Equatable {
    var id: String { "\(code)-\(name)" }
    let code: String
    let name: String
}

/// NLM ClinicalTables ICD-10 API returns an ARRAY:
/// [count, [codes], null, [[code, name], ...]]
struct ICD10Response: Decodable, Equatable {
    let count: Int
    let suggestions: [ICDSuggestion]

    init(from decoder: Decoder) throws {
        var c = try decoder.unkeyedContainer()

        // index 0: count
        self.count = try c.decode(Int.self)

        // index 1: codes (we don't need them for UI)
        _ = try c.decode([String].self)

        // index 2: null (legacy/unused) — ignore safely
        _ = try c.decodeNil()

        // index 3: display rows [[code, name], ...]
        let rows = try c.decode([[String]].self)

        self.suggestions = rows.compactMap { row in
            guard row.count >= 2 else { return nil }
            return ICDSuggestion(code: row[0], name: row[1])
        }
    }
}

@MainActor
final class ICD10Service: ObservableObject {
    @Published private(set) var suggestions: [ICDSuggestion] = []

    private var searchTask: Task<Void, Never>?
    private let session: URLSession
    private let decoder: JSONDecoder
    private let debounceNanos: UInt64

    /// Used to ignore stale async responses (old term finishes after new one).
    private var latestTerm: String = ""

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        debounceMilliseconds: UInt64 = 250
    ) {
        self.session = session
        self.decoder = decoder
        self.debounceNanos = debounceMilliseconds * 1_000_000
    }

    func search(term: String) {
        searchTask?.cancel()

        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        latestTerm = trimmed

        // If short/empty, clear suggestions immediately and don't fetch
        guard trimmed.count >= 2 else {
            suggestions = []
            return
        }

        searchTask = Task { [weak self] in
            guard let self else { return }

            // debounce
            try? await Task.sleep(nanoseconds: debounceNanos)
            guard !Task.isCancelled else { return }

            await self.fetch(term: trimmed)
        }
    }

    private func fetch(term: String) async {
        var components = URLComponents(string: "https://clinicaltables.nlm.nih.gov/api/icd10cm/v3/search")!
        components.queryItems = [
            URLQueryItem(name: "sf", value: "code,name"),
            URLQueryItem(name: "terms", value: term)
        ]

        guard let url = components.url else { return }

        do {
            let (data, _) = try await session.data(from: url)

            // If user typed something else while we were waiting, ignore this response
            guard term == latestTerm else { return }

            let decoded = try decoder.decode(ICD10Response.self, from: data)

            // Guard again in case decoding took time and term changed
            guard term == latestTerm else { return }

            suggestions = decoded.suggestions
        } catch {
            // If cancelled, do nothing special (common during typing)
            if let e = error as? URLError, e.code == .cancelled { return }

            // Only clear if this request is still the latest
            guard term == latestTerm else { return }
            suggestions = []
        }
    }
}
