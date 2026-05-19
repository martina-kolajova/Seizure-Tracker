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
/// [count, [codes], extra_data_or_null, [[code, name], ...]]
struct ICD10Response: Decodable, Equatable {
    let count: Int
    let suggestions: [ICDSuggestion]

    init(from decoder: Decoder) throws {
        var c = try decoder.unkeyedContainer()

        // index 0: count
        self.count = (try? c.decode(Int.self)) ?? 0

        // index 1: codes — skip
        _ = try? c.decode([String].self)

        // index 2: extra data — can be null, dict, or array. Skip safely.
        if (try? c.decodeNil()) == true {
            // null — consumed
        } else if (try? c.decode([String: [String]].self)) != nil {
            // dict — consumed
        } else if (try? c.decode([String].self)) != nil {
            // array — consumed
        } else {
            _ = try? c.decode(EmptyDecodable.self)
        }

        // index 3: display rows — may be [code, name] or just [code]
        let rows = (try? c.decode([[String]].self)) ?? []

        self.suggestions = rows.compactMap { row in
            guard let code = row.first else { return nil }
            let name = row.count >= 2 ? row[1] : code
            return ICDSuggestion(code: code, name: name)
        }
    }
}

private struct EmptyDecodable: Decodable {}

@MainActor
final class ICD10Service: ObservableObject {
    @Published private(set) var suggestions: [ICDSuggestion] = []

    private var searchTask: Task<Void, Never>?
    private let session: URLSession
    private let decoder: JSONDecoder
    private let debounceNanos: UInt64
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

        guard trimmed.count >= 2 else {
            suggestions = []
            return
        }

        searchTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: debounceNanos)
            guard !Task.isCancelled else { return }
            await self.fetch(term: trimmed)
        }
    }

    private func fetch(term: String) async {
        var components = URLComponents(string: "https://clinicaltables.nlm.nih.gov/api/icd10cm/v3/search")!
        components.queryItems = [
            URLQueryItem(name: "terms",   value: term),
            URLQueryItem(name: "sf",      value: "code,name"),
            URLQueryItem(name: "df",      value: "code,name"),   // ⬅️ CRITICAL: ensures rows are [code, name]
            URLQueryItem(name: "maxList", value: "25")
        ]

        guard let url = components.url else { return }

        do {
            let (data, response) = try await session.data(from: url)
            guard term == latestTerm else { return }

            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                print("🟥 ICD10 HTTP \(http.statusCode) for \"\(term)\"")
                suggestions = []
                return
            }

            let decoded = try decoder.decode(ICD10Response.self, from: data)
            guard term == latestTerm else { return }

            print("🟩 ICD10: \(decoded.suggestions.count) suggestions for \"\(term)\"")
            suggestions = decoded.suggestions
        } catch {
            if let e = error as? URLError, e.code == .cancelled { return }
            print("🟥 ICD10 error for \"\(term)\":", error.localizedDescription)
            guard term == latestTerm else { return }
            suggestions = []
        }
    }
}
