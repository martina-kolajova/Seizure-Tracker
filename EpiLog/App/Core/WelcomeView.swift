//
//  WelcomeView.swift
//  Seizure Tracker
//
//  Pure layout. Animation state lives in WelcomeViewModel /
//  WelcomeStatPageViewModel.
//

import SwiftUI

// MARK: - Generated EpiLog Logo (pure shape, no logic)
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

// MARK: - Welcome View (splash)
struct WelcomeView: View {
    let onStart: () -> Void  // kept for signature compatibility, not called internally

    @StateObject private var vm = WelcomeViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            EpiLogLogo(size: 90)
                .scaleEffect(vm.logoScale * (vm.logoPulse ? 1.06 : 1.0))
                .opacity(vm.logoOpacity)
                .animation(vm.pulseAnimation, value: vm.logoPulse)

            Text("EpiLog")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
                .opacity(vm.textOpacity)
                .offset(y: vm.textOffset)

            Text("A simple, personal way to log seizures.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .opacity(vm.textOpacity)
                .offset(y: vm.textOffset)

            Spacer()

            // swipe hint
            VStack(spacing: 4) {
                Image(systemName: "chevron.up")
                Image(systemName: "chevron.up")
                    .opacity(0.5)
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white.opacity(0.5))
            .opacity(vm.textOpacity)
            .padding(.bottom, 36)
        }
        .onAppear { vm.start() }
    }
}

// MARK: - World Map Backdrop (uses world.png from Assets)
struct WorldMapBackdrop: View {
    var body: some View {
        Image("world")
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .foregroundStyle(.white.opacity(1.5))
            .allowsHitTesting(false)
    }
}

// MARK: - Reusable onboarding stat page (image on top, info below)
struct WelcomeStatPage: View {
    let bigStat: String
    let bigStatCaption: String
    let title: String
    let bodyText: String
    let pageIndex: Int
    let totalPages: Int
    /// Asset image name to use as the backdrop. Defaults to the world map.
    var backdropImageName: String = "world"

    @StateObject private var vm = WelcomeStatPageViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // ── Top: backdrop image (PNG asset, tinted white) ──
            Image(backdropImageName)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundStyle(.white.opacity(0.85))
                .frame(maxWidth: .infinity)
                .frame(height: 380)
                .padding(.top, 50)

            // ── Bottom: information block ──
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .padding(.top, 22)

                Text(bigStat)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(bigStatCaption)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text(bodyText)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.80))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 32)
                    .padding(.top, 6)
            }

            Spacer()

            // page-dot indicator
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { i in
                    Circle()
                        .fill(.white.opacity(i == pageIndex ? 0.95 : 0.30))
                        .frame(width: 7, height: 7)
                }
            }

            // swipe hint
            VStack(spacing: 4) {
                Image(systemName: "chevron.up")
                Image(systemName: "chevron.up").opacity(0.5)
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white.opacity(0.55))
            .padding(.top, 14)
            .padding(.bottom, 30)
        }
        .opacity(vm.contentOpacity)
        .offset(y: vm.contentOffset)
        .onAppear { vm.start() }
    }
}

#Preview {
    ContentView()
}
