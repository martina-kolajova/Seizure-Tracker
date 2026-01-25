//
//  MoodChoice.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 10.01.2026.
import Foundation
import SwiftUI

// enum: 
enum MoodChoice: String, CaseIterable, Identifiable {
    case good = "🙂 Good"
    case ok = "😐 OK"
    case low = "😟 Low"
    var id: String { rawValue }
}

enum SleepChoice: String, CaseIterable, Identifiable {
    case good = "Good"
    case ok = "OK"
    case poor = "Poor"
    var id: String { rawValue }
}

enum StressChoice: String, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    var id: String { rawValue }
}

enum TriggerChoice: String, CaseIterable, Identifiable, Hashable {
    case none = "None"
    case missedMeds = "Missed meds"
    case sleepDeprivation = "Sleep loss"
    case illness = "Illness"
    case alcohol = "Alcohol"
    case screen = "Screen"
    case period = "Period"
    case other = "Other"
    var id: String { rawValue }
}


