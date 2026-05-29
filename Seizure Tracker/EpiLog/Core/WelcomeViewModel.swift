//
//  WelcomeViewModel.swift
//  Seizure Tracker
//
//  Animation state for WelcomeView and WelcomeStatPage.
//  Keeps the views pure layout.
//

import SwiftUI

// MARK: - WelcomeView (splash)

@MainActor
final class WelcomeViewModel: ObservableObject {
    @Published var logoScale: CGFloat = 0.4
    @Published var logoOpacity: Double = 0
    @Published var textOpacity: Double = 0
    @Published var textOffset: CGFloat = 20
    @Published var logoPulse: Bool = false

    let pulseAnimation: Animation =
        .easeInOut(duration: 2.2).repeatForever(autoreverses: true)

    /// Runs the splash entrance choreography: logo springs in, text fades up,
    /// then the logo starts gently pulsing.
    func start() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.1)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.45)) {
            textOpacity = 1.0
            textOffset = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.logoPulse = true
        }
    }
}

// MARK: - WelcomeStatPage (50M / 70% etc.)

@MainActor
final class WelcomeStatPageViewModel: ObservableObject {
    @Published var contentOpacity: Double = 0
    @Published var contentOffset: CGFloat = 30

    /// Fades + slides the whole page into place.
    func start() {
        withAnimation(.easeOut(duration: 0.55).delay(0.1)) {
            contentOpacity = 1
            contentOffset = 0
        }
    }
}
