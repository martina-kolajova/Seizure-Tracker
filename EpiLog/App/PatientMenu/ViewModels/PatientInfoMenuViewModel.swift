//
//  PatientInfoMenuViewModel.swift
//  EpiLog
//
//  Layout math and gesture decisions for the patient-profile menu screen.
//  Pure value type — no observable state, so no need for ObservableObject.
//

import SwiftUI
import Foundation

struct PatientInfoMenuViewModel {

    // MARK: - Decorative rings
    let ringDiameters: [CGFloat] = [200, 280, 360, 440]

    /// Anchor for the four concentric rings (slightly off-screen left, near vertical center).
    func ringCenter(in size: CGSize) -> CGPoint {
        CGPoint(x: -20, y: size.height * 0.55)
    }

    // MARK: - Radial button placement

    /// Centre point that the navigation pills orbit around.
    func buttonOrbitCenter(in size: CGSize) -> CGPoint {
        CGPoint(x: size.width * 0.35, y: size.height * 0.55)
    }

    /// Distance from `buttonOrbitCenter` to each pill.
    let buttonOrbitRadius: CGFloat = 170

    /// Arc spans -55° (top) to +55° (bottom) on the right side of the orbit.
    private let startAngle: Double = -55.0 * .pi / 180.0
    private let endAngle:   Double =  55.0 * .pi / 180.0

    /// Position for the pill at `index` of `count` evenly spaced along the arc.
    func buttonPosition(index: Int, count: Int, in size: CGSize) -> CGPoint {
        let center = buttonOrbitCenter(in: size)
        let step = count > 1 ? (endAngle - startAngle) / Double(count - 1) : 0
        let angle = startAngle + Double(index) * step
        let cosA = CGFloat(Foundation.cos(angle))
        let sinA = CGFloat(Foundation.sin(angle))
        return CGPoint(
            x: center.x + cosA * buttonOrbitRadius,
            y: center.y + sinA * buttonOrbitRadius
        )
    }

    // MARK: - Gesture decisions

    private let swipeDistanceThreshold: CGFloat = 60
    private let swipeVelocityThreshold: CGFloat = 300

    /// Returns true when the drag should trigger the "continue → tracker" action.
    /// (Predominantly horizontal swipe, leftward, past distance or velocity threshold.)
    func shouldContinueOnSwipe(_ value: DragGesture.Value) -> Bool {
        let dx = value.translation.width
        let dy = value.translation.height
        let vx = value.predictedEndTranslation.width
        guard abs(dx) > abs(dy) else { return false }
        return dx < -swipeDistanceThreshold || vx < -swipeVelocityThreshold
    }
}
