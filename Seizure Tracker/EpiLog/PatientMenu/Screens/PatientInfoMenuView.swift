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
        GeometryReader { geo in
            ZStack {
                // ── Decorative concentric rings (behind buttons) ──
                decorativeRings(in: geo)

                // ── Buttons arranged around the rings (right-facing arc) ──
                radialButtons(in: geo)

                // ── Title at top, chevrons at bottom ──
                VStack(spacing: 0) {
                    VStack(spacing: 4) {
                        Text("SET UP")
                            .font(.system(size: 18, weight: .medium))
                            .tracking(4)
                            .foregroundColor(.white.opacity(0.5))

                        Text("Patient Profile")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .kerning(-0.5)
                    }
                    .padding(.top, 60)

                    Spacer()

                    Text("›  ›  ›")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.45))
                        .contentShape(Rectangle())
                        .onTapGesture { onContinue() }
                        .padding(.bottom, 40)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 25)
                .onEnded { v in
                    let dx = v.translation.width
                    let dy = v.translation.height
                    let vx = v.predictedEndTranslation.width
                    // swipe left → tracker
                    if abs(dx) > abs(dy) && (dx < -60 || vx < -300) {
                        onContinue()
                    }
                }
        )
    }

    // MARK: - Decorative rings (behind buttons)
    private func decorativeRings(in geo: GeometryProxy) -> some View {
        ZStack {
            ForEach([200.0, 280.0, 360.0, 440.0], id: \.self) { d in
                Circle()
                    .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
                    .frame(width: d, height: d)
            }
        }
        .position(x: -20, y: geo.size.height * 0.55)
        .allowsHitTesting(false)
    }

    // MARK: - Buttons arranged around the ring center
    private func radialButtons(in geo: GeometryProxy) -> some View {
        // Buttons orbit a point on the right side of the screen,
        // away from the decorative ring center on the left.
        let center = CGPoint(x: geo.size.width * 0.35, y: geo.size.height * 0.55)
        let radius: CGFloat = 170

        let sections = InfoSection.allCases
        let count = sections.count
        // Arc spanning from -55° (upper-right) to +55° (lower-right)
        let startAngle = -55.0 * .pi / 180.0
        let endAngle   =  55.0 * .pi / 180.0
        let step = count > 1 ? (endAngle - startAngle) / Double(count - 1) : 0

        return ZStack {
            ForEach(Array(sections.enumerated()), id: \.element) { i, section in
                let angle = startAngle + Double(i) * step
                let x = center.x + cos(angle) * radius
                let y = center.y + sin(angle) * radius

                NavigationLink(value: section) {
                    PatientInfoSectionPill(section: section)
                }
                .buttonStyle(.plain)
                .position(x: x, y: y)
            }
        }
    }
}


#Preview {
    PatientInfoMenuView(onBack: {}, onContinue: {})
        .background(AppGradient())
}
