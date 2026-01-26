//
//  InfoSection.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 16.12.2025.
//


import SwiftUI


enum InfoSection: String, CaseIterable, Identifiable, Hashable {
    case personal   = "Personal info"
    case diagnosis  = "Diagnosis"
    case medication = "Medication"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .personal:   return "heart.text.square"
        case .diagnosis:  return "waveform.path.ecg"
        case .medication: return "pills.fill"
        }
    }
}

// ✅ Must be Codable because PatientProfile is Codable
enum HeightUnit: String, CaseIterable, Codable, Hashable { case cm, ftIn }
enum WeightUnit: String, CaseIterable, Codable, Hashable { case kg, lb }

// ✅ Central patient model (single source of truth)
struct PatientProfile: Codable, Hashable {

    // Personal
    var firstName: String = ""
    var lastName: String = ""
    var ageText: String = ""                 // keep as String (matches your UI)
    var heightValue: String = ""
    var weightValue: String = ""
    var heightUnit: HeightUnit = .cm
    var weightUnit: WeightUnit = .kg
    var personalNotes: String = ""

    // Diagnosis
    var diagnosisText: String = ""
    var diagnosisYear: String = ""

    // Medication
    var medicationText: String = ""
    var medicationNotes: String = ""
}


