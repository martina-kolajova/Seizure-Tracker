import Foundation

struct ICDCode: Identifiable {
    let id = UUID()
    let code: String
    let name: String
}

@MainActor
class ICD10Service: ObservableObject {
    @Published var suggestions: [ICDCode] = []

    private var searchTask: Task<Void, Never>?

    func search(term: String) {
        // Cancel previous search (debounce)
        searchTask?.cancel()

        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            suggestions = []
            return
        }

        searchTask = Task {
            // small delay so we don't call on every keystroke
            try? await Task.sleep(for: .milliseconds(250))
            guard !Task.isCancelled else { return }
            await fetch(term: trimmed)
        }
    }

    private func fetch(term: String) async {
        var components = URLComponents(string: "https://clinicaltables.nlm.nih.gov/api/icd10cm/v3/search")!
        components.queryItems = [
            .init(name: "sf", value: "code,name"),
            .init(name: "df", value: "code,name"),
            .init(name: "terms", value: term),
            .init(name: "maxList", value: "15")
        ]

        guard let url = components.url else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            // Response is a top-level JSON array, not an object:
            // [ totalCount, [codes...], null-or-extra, [[code,name], ...] ]
            guard let root = try JSONSerialization.jsonObject(with: data) as? [Any],
                  root.count >= 4,
                  let codes = root[1] as? [String],
                  let display = root[3] as? [[Any]] else {
                return
            }

            var results: [ICDCode] = []
            for (idx, code) in codes.enumerated() {
                guard idx < display.count,
                      let pair = display[idx] as? [Any],
                      pair.count >= 2,
                      let name = pair[1] as? String else { continue }

                results.append(ICDCode(code: code, name: name))
            }

            suggestions = results
        } catch {
            print("ICD10 API error:", error)
        }
    }
}
