//
//  MeshGradientView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 02.12.2025.
//

import SwiftUI




struct MeshGradientView: View {
    /// Kept for API compatibility.
    var frozen: Bool = false

    var body: some View {
        // TimelineView drives the animation from absolute time, so EVERY
        // instance of MeshGradientView shows the exact same frame at the
        // same moment. When two instances overlap (e.g. one inside a sliding
        // NavigationStack and one in the background), they look like one
        // continuous gradient — no visible seam during the swipe.
        TimelineView(.animation(minimumInterval: 1.0/60.0)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            // Smooth 0…1 oscillation, ~10s period
            let phase = (sin(t * .pi / 5.0) + 1) / 2
            let f = Float(phase)
            let d = Double(phase)

            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5],
                    [0.1 + 0.7 * (1 - f), 0.5],
                    [1.0, 0.5 + 0.5 * (1 - f)],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: [
                    .purple, .indigo, .purple,
                    Color(hue: 0.55 + 0.15 * d, saturation: 0.7, brightness: 0.85),
                    .blue, .blue,
                    .purple, .indigo, .purple
                ]
            )
            .ignoresSafeArea()
        }
    }
}

// #Preview {
// //     MeshGradientView()
// // }
