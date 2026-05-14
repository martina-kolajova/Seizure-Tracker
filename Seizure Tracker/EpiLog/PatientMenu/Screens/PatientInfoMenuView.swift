//
//  PatientInfoMenuView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 16.12.2025.
//


import SwiftUI

struct PatientInfoMenuView: View {
    let onBack: () -> Void
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            topBar

            HStack {
                GeometryReader { geo in
                    ZStack {
                        let circleCenter = CGPoint(
                            x: -geo.size.width * 0.10,
                            y: geo.size.height * 0.5
                        )

                        Image("logo-white")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white.opacity(0.7))
                            .scaledToFit()
                            .frame(width: geo.size.height * 2)
                            .position(circleCenter)
                            .allowsHitTesting(false)

                        let totalSections = InfoSection.allCases.count
                        let radius = geo.size.height * 0.36

                        let startAngle = -60.0 * .pi / 180.0
                        let endAngle   =  60.0 * .pi / 180.0
                        let angleStep  = totalSections > 1
                        ? (endAngle - startAngle) / Double(totalSections - 1)
                        : 0

                        let buttonOffsetX = geo.size.width * 0.22

                        ForEach(Array(InfoSection.allCases.enumerated()), id: \.1) { index, section in
                            let angle = startAngle + Double(index) * angleStep

                            let baseX = circleCenter.x + cos(angle) * radius
                            let baseY = circleCenter.y + sin(angle) * radius

                            let x = baseX + buttonOffsetX
                            let y = baseY

                            NavigationLink(value: section) {
                                PatientInfoSectionPill(section: section)
                            }
                            .buttonStyle(.plain)
                            .position(x: x, y: y)
                        }
                    }
                }
                .frame(width: 260)

                Spacer()
            }
            .padding(.top, 10)
            .padding(.leading, 8)

            Spacer()

            bottomButton
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 25)
                .onEnded { v in
                    let dx = v.translation.width
                    let dy = v.translation.height
                    let vx = v.predictedEndTranslation.width
                    // swipe left (or fast left flick) → tracker
                    if abs(dx) > abs(dy) && (dx < -60 || vx < -300) {
                        onContinue()
                    }
                }
        )
    }

    private var topBar: some View {
        Text("Set up patient profile")
            .foregroundColor(.white)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.top, 40)
    }

    private var bottomButton: some View {
        TrackerHint(onTap: onContinue)
            .padding(.bottom, 40)
    }
}

private struct TrackerHint: View {
    let onTap: () -> Void
    @State private var tick: Int = 0

    private let chevronCount = 3

    var body: some View {
        VStack(spacing: 8) {
            Text("Tracker")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            // Stationary chevrons — sequential fade gives the illusion of running
            HStack(spacing: 6) {
                ForEach(0..<chevronCount, id: \.self) { i in
                    Image(systemName: "chevron.right")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(tick == i ? 0.85 : 0.55)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.30)) {
                    tick = (tick + 1) % chevronCount
                }
            }
        }
    }
}

