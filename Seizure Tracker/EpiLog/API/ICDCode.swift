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

    /// Unique identifier required by SwiftUI.
    /// Used for diffing and animations in lists (`ForEach`, `List`).
    let id = UUID()

    /// ICD-10 diagnosis code (e.g. "A00.0")
    let code: String

    /// Human-readable diagnosis name
    /// (e.g. "Cholera due to Vibrio cholerae 01, biovar cholerae")
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

    func fetch(term: String) async {
        var components = URLComponents(string: "https://clinicaltables.nlm.nih.gov/api/icd10cm/v3/search")!
        components.queryItems = [
            URLQueryItem(name: "sf", value: "code,name"),
            URLQueryItem(name: "terms", value: term)
        ]

        guard let url = components.url else { return }

        do {
            let (data, _) = try await session.data(from: url)
            let decoded = try decoder.decode(ICD10Response.self, from: data)
            suggestions = decoded.suggestions
        } catch {
            // If cancelled, do nothing special (common during typing)
            if let e = error as? URLError, e.code == .cancelled { return }
            suggestions = []
        }
    }
}
