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

// MARK: - Welcome View (pure content, no gesture — ContentView drives navigation)
struct WelcomeView: View {
    let onStart: () -> Void  // kept for signature compatibility, not called internally

    @State private var logoScale: CGFloat = 0.4
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var logoPulse: Bool = false

    var body: some View {
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

            // swipe hint
            VStack(spacing: 4) {
                Image(systemName: "chevron.up")
                Image(systemName: "chevron.up")
                    .opacity(0.5)
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white.opacity(0.5))
            .opacity(textOpacity)
            .padding(.bottom, 36)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.1)) {
                logoScale = 1.0; logoOpacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { logoPulse = true }
            withAnimation(.easeOut(duration: 0.6).delay(0.45)) {
                textOpacity = 1.0; textOffset = 0
            }
        }
    }
}

// MARK: - World Map Outline (simplified continent shapes drawn as paths)
struct WorldMapShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * w, y: rect.minY + y * h)
        }

        // ── North America ──
        var na = Path()
        na.move(to: pt(0.10, 0.30))
        na.addCurve(to: pt(0.28, 0.25), control1: pt(0.15, 0.20), control2: pt(0.23, 0.20))
        na.addCurve(to: pt(0.30, 0.45), control1: pt(0.32, 0.30), control2: pt(0.32, 0.40))
        na.addCurve(to: pt(0.22, 0.52), control1: pt(0.27, 0.48), control2: pt(0.25, 0.52))
        na.addCurve(to: pt(0.18, 0.48), control1: pt(0.20, 0.55), control2: pt(0.17, 0.52))
        na.addCurve(to: pt(0.10, 0.30), control1: pt(0.12, 0.45), control2: pt(0.08, 0.38))
        p.addPath(na)

        // ── South America ──
        var sa = Path()
        sa.move(to: pt(0.25, 0.55))
        sa.addCurve(to: pt(0.32, 0.62), control1: pt(0.29, 0.55), control2: pt(0.32, 0.58))
        sa.addCurve(to: pt(0.28, 0.85), control1: pt(0.33, 0.72), control2: pt(0.30, 0.80))
        sa.addCurve(to: pt(0.22, 0.78), control1: pt(0.25, 0.88), control2: pt(0.21, 0.83))
        sa.addCurve(to: pt(0.25, 0.55), control1: pt(0.22, 0.70), control2: pt(0.23, 0.62))
        p.addPath(sa)

        // ── Europe ──
        var eu = Path()
        eu.move(to: pt(0.46, 0.30))
        eu.addCurve(to: pt(0.56, 0.30), control1: pt(0.50, 0.26), control2: pt(0.54, 0.26))
        eu.addCurve(to: pt(0.55, 0.42), control1: pt(0.57, 0.34), control2: pt(0.56, 0.40))
        eu.addCurve(to: pt(0.46, 0.40), control1: pt(0.51, 0.44), control2: pt(0.48, 0.43))
        eu.addCurve(to: pt(0.46, 0.30), control1: pt(0.45, 0.36), control2: pt(0.45, 0.33))
        p.addPath(eu)

        // ── Africa ──
        var af = Path()
        af.move(to: pt(0.48, 0.45))
        af.addCurve(to: pt(0.60, 0.50), control1: pt(0.54, 0.43), control2: pt(0.58, 0.46))
        af.addCurve(to: pt(0.56, 0.78), control1: pt(0.62, 0.62), control2: pt(0.60, 0.72))
        af.addCurve(to: pt(0.50, 0.78), control1: pt(0.54, 0.82), control2: pt(0.50, 0.82))
        af.addCurve(to: pt(0.46, 0.60), control1: pt(0.48, 0.72), control2: pt(0.46, 0.66))
        af.addCurve(to: pt(0.48, 0.45), control1: pt(0.46, 0.52), control2: pt(0.46, 0.48))
        p.addPath(af)

        // ── Asia ──
        var asia = Path()
        asia.move(to: pt(0.56, 0.25))
        asia.addCurve(to: pt(0.88, 0.30), control1: pt(0.66, 0.18), control2: pt(0.80, 0.20))
        asia.addCurve(to: pt(0.84, 0.50), control1: pt(0.92, 0.38), control2: pt(0.88, 0.46))
        asia.addCurve(to: pt(0.70, 0.55), control1: pt(0.78, 0.55), control2: pt(0.74, 0.55))
        asia.addCurve(to: pt(0.58, 0.45), control1: pt(0.64, 0.55), control2: pt(0.60, 0.50))
        asia.addCurve(to: pt(0.56, 0.25), control1: pt(0.55, 0.38), control2: pt(0.54, 0.30))
        p.addPath(asia)

        // ── Australia ──
        var au = Path()
        au.move(to: pt(0.78, 0.68))
        au.addCurve(to: pt(0.92, 0.68), control1: pt(0.84, 0.65), control2: pt(0.90, 0.65))
        au.addCurve(to: pt(0.88, 0.78), control1: pt(0.94, 0.74), control2: pt(0.91, 0.78))
        au.addCurve(to: pt(0.78, 0.74), control1: pt(0.84, 0.80), control2: pt(0.80, 0.78))
        au.addCurve(to: pt(0.78, 0.68), control1: pt(0.76, 0.71), control2: pt(0.76, 0.69))
        p.addPath(au)

        return p
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

    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30

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
                // Title comes FIRST (e.g. "You're not alone.")
                Text(title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .padding(.top, 22)

                // Then the stat (smaller than before)
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
        .opacity(contentOpacity)
        .offset(y: contentOffset)
        .onAppear {
            withAnimation(.easeOut(duration: 0.55).delay(0.1)) {
                contentOpacity = 1
                contentOffset = 0
            }
        }
    }
}

#Preview {
    ContentView()
}
