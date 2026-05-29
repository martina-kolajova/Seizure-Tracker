//
//  AppCoordinatorViewModel.swift
//  Seizure Tracker
//
//  Owns all navigation/drag state for the root canvas
//  (splash → stat pages → patient info → tracker).
//

import SwiftUI

@MainActor
final class AppCoordinatorViewModel: ObservableObject {

    // MARK: - Top-level screens that sit on top of the vertical canvas
    enum TopScreen { case none, tracker }

    // MARK: - Published UI state
    @Published var slot: Int = 0           // 0 splash, 1 stat1, 2 stat2, 3 patient info
    @Published var dragOffset: CGFloat = 0
    @Published var topScreen: TopScreen = .none
    @Published var isDragging: Bool = false

    // MARK: - Constants
    let maxSlot: Int = 3
    let spring: Animation = .spring(response: 0.5, dampingFraction: 0.86)

    // MARK: - Derived
    var meshOpacity: Double { slot == 0 ? 1.0 : 0.0 }
    var trackerShown: Bool { topScreen == .tracker }

    func patientDisplayName(from store: EpiLogStore) -> String {
        let first = store.patient.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let last  = store.patient.lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let full  = "\(first) \(last)".trimmingCharacters(in: .whitespacesAndNewlines)
        return full.isEmpty ? "Patient" : full
    }

    func canvasOffset(slotHeight h: CGFloat) -> CGFloat {
        -CGFloat(slot) * h + dragOffset
    }

    // MARK: - Drag handling
    func handleDragChanged(_ value: DragGesture.Value) {
        isDragging = true
        let drag = value.translation.height
        // Rubber-band at the canvas edges
        if (slot == 0 && drag > 0) || (slot == maxSlot && drag < 0) {
            dragOffset = drag * 0.08
        } else {
            dragOffset = drag
        }
    }

    func handleDragEnded(_ value: DragGesture.Value) {
        isDragging = false
        let vel = value.predictedEndTranslation.height
        let up   = value.translation.height < -60 || vel < -300
        let down = value.translation.height >  60 || vel >  300

        if up {
            withAnimation(spring) {
                slot = min(slot + 1, maxSlot)
                dragOffset = 0
            }
        } else if down {
            withAnimation(spring) {
                slot = max(slot - 1, 0)
                dragOffset = 0
            }
        } else {
            withAnimation(spring) { dragOffset = 0 }
        }
    }

    // MARK: - Navigation actions
    func openTracker() {
        withAnimation(spring) { topScreen = .tracker }
    }

    func closeTracker() {
        withAnimation(spring) { topScreen = .none }
    }

    /// Splash auto-advances to the first stat page after a brief delay.
    func scheduleSplashAutoAdvance(after seconds: Double = 2.8) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
            guard let self else { return }
            if self.slot == 0 {
                withAnimation(self.spring) { self.slot = 1 }
            }
        }
    }
}
