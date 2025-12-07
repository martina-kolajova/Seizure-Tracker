//
//  ICDCode.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 04.12.2025.
//
import Foundation
import SwiftUI

struct ICDSuggestion: Identifiable {
    let id = UUID()
    let code: String
    let name: String
}

class ICD10Service: ObservableObject {
    @Published var suggestions: [ICDSuggestion] = []
    
    private var currentTask: URLSessionDataTask?
    
    func search(term: String) {
        // Avoid spamming API for tiny inputs
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            DispatchQueue.main.async {
                self.suggestions = []
            }
            return
        }
        
        // Cancel previous request if user keeps typing
        currentTask?.cancel()
        
        var components = URLComponents(string: "https://clinicaltables.nlm.nih.gov/api/icd10cm/v3/search")!
        components.queryItems = [
            URLQueryItem(name: "sf", value: "code,name"),
            URLQueryItem(name: "terms", value: trimmed)
        ]
        
        guard let url = components.url else { return }
        print("ICD URL:", url.absoluteString)
        
        currentTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self else { return }
            
            if let error = error as? URLError, error.code == .cancelled {
                // request cancelled because user kept typing
                return
            }
            
            guard let data = data, error == nil else {
                print("ICD search error:", error?.localizedDescription ?? "unknown")
                return
            }
            
            do {
                // Response is: [count, [codes], ???, [[code, name], ...]]
                guard let root = try JSONSerialization.jsonObject(with: data) as? [Any],
                      root.count >= 4,
                      let displayArray = root[3] as? [[Any]] else {
                    print("Unexpected ICD response format:", String(data: data, encoding: .utf8) ?? "no string")
                    return
                }
                
                let newSuggestions: [ICDSuggestion] = displayArray.compactMap { item in
                    guard item.count >= 2,
                          let code = item[0] as? String,
                          let name = item[1] as? String else {
                        return nil
                    }
                    return ICDSuggestion(code: code, name: name)
                }
                
                DispatchQueue.main.async {
                    self.suggestions = newSuggestions
                    print("Got \(newSuggestions.count) ICD suggestions")
                }
            } catch {
                print("JSON parse error:", error)
            }
        }
        
        currentTask?.resume()
    }
}
