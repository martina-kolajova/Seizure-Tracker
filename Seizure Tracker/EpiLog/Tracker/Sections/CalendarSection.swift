//
//  calender.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 03.01.2026.
//

import SwiftUI

extension TrackerLayout {
//    $ binding

    var calendarStrip: some View {
        CalendarStrip(
            selectedDate: $vm.selectedDate,
//            violetPhase: vm.violetPhase
        )
        .padding(.top, 8)
    }
}
