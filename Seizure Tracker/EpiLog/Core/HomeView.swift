//
//  HomeView.swift
//  Seizure Tracker
//
//  Created by GitHub Copilot on 05.05.2026.
//

import SwiftUI

struct HomeView: View {
    let onContinue: () -> Void

    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30
    @State private var swipeHintOffset: CGFloat = 0
    @State private var swipeHintOpacity: Double = 0

    var body: some View {
        ZStack {
            VStack(spacing: 28) {
                Spacer()

                EpiLogLogo(size: 70)
                    .opacity(contentOpacity)

                Text("Welcome to EpiLog")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)

                Text("Your seizure log is ready.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.75))
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)

                Spacer()

                // Swipe hint
                VStack(spacing: 6) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Swipe up to continue")
                        .font(.caption)
                }
                .foregroundColor(.white.opacity(0.6))
                .offset(y: swipeHintOffset)
                .opacity(swipeHintOpacity)
                .padding(.bottom, 40)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 40)
                .onEnded { value in
                    if value.translation.height < -40 {
                        onContinue()
                    }
                }
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.15)) {
                contentOpacity = 1
                contentOffset = 0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
                swipeHintOpacity = 1
            }
            // Gentle floating animation for the hint
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true).delay(0.8)) {
                swipeHintOffset = -6
            }
        }
    }
}

#Preview {
    HomeView(onContinue: {})
}
