//
//  WelcomeView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 02.12.2025.
//
import SwiftUI

// MARK: - Generated EpiLog Logo
struct EpiLogLogo: View {
    var size: CGFloat = 80
    var color: Color = .white

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.30), lineWidth: size * 0.045)
                .frame(width: size, height: size)
            Circle()
                .stroke(color.opacity(0.50), lineWidth: size * 0.05)
                .frame(width: size * 0.74, height: size * 0.74)
            Circle()
                .stroke(color.opacity(0.70), lineWidth: size * 0.055)
                .frame(width: size * 0.50, height: size * 0.50)
            Circle()
                .stroke(color, lineWidth: size * 0.055)
                .frame(width: size * 0.26, height: size * 0.26)
        }
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    let onStart: () -> Void

    @State private var logoScale: CGFloat = 0.4
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var logoPulse: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()

                EpiLogLogo(size: 90)
                    .scaleEffect(logoScale * (logoPulse ? 1.06 : 1.0))
                    .opacity(logoOpacity)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: logoPulse)

                Text("EpiLog")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(textOpacity)
                    .offset(y: textOffset)

                Text("A simple, personal way to log seizures.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(textOpacity)
                    .offset(y: textOffset)

                Spacer()
            }
        }
        .onAppear { runEntrance() }
    }

    private func runEntrance() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.1)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            logoPulse = true
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.45)) {
            textOpacity = 1.0
            textOffset = 0
        }
        // Auto-advance after splash
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            onStart()
        }
    }
}

#Preview {
    ContentView()
}
