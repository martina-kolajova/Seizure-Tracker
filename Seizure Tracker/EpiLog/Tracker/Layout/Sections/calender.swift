//
//  calender.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 03.01.2026.
//

import SwiftUI

extension TrackerLayout {

    // MARK: - Calendar strip
    var calendarStrip: some View {
        CalendarStrip(
            selectedDate: $selectedDate,
            violetPhase: violetPhase
        )
        .padding(.top, 8)
    }
}
