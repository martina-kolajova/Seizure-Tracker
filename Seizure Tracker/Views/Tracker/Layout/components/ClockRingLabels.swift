//
//  ClockRingLabels.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 03.01.2026.
//


import SwiftUI

struct ClockRingLabels: View {
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = size * 0.53

            ZStack {
                label("12", at: point(center: center, radius: radius, angleDeg: -90))
                label("3",  at: point(center: center, radius: radius, angleDeg:   0))
                label("6",  at: point(center: center, radius: radius, angleDeg:  90))
                label("9",  at: point(center: center, radius: radius, angleDeg: 180))
            }
        }
    }

    private func label(_ text: String, at p: CGPoint) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundColor(.white.opacity(0.85))
            .position(p)
    }

    private func point(center: CGPoint, radius: CGFloat, angleDeg: Double) -> CGPoint {
        let a = CGFloat(angleDeg) * .pi / 180
        return CGPoint(
            x: center.x + radius * cos(a),
            y: center.y + radius * sin(a)
        )
    }
}
