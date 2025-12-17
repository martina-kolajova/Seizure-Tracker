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

enum HeightUnit: String, CaseIterable { case cm, ftIn }
enum WeightUnit: String, CaseIterable { case kg, lb }
