//
//  GrowingCenterBar.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 03.01.2026.
//


import SwiftUI

struct GrowingCenterBar: View {
    /// 0...1
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            let w = geo.size.width
            let filled = max(0, min(1, progress)) * h

            ZStack(alignment: .bottom) {
                Capsule()
                    .fill(.white.opacity(0.12))
                    .frame(width: w, height: h)

                Capsule()
                    .fill(.white.opacity(0.85))
                    .frame(width: w, height: filled)
            }
            .overlay(Capsule().stroke(.white.opacity(0.20), lineWidth: 1))
        }
    }
}
