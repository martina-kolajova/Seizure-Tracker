//
//  TrackerLayout.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 18.12.2025.
//
import SwiftUI

import SwiftUI

struct TrackerLayout: View {
    let patientName: String
    let onBack: () -> Void

    @Binding var todayCount: Int
    @Binding var totalCount: Int
    @Binding var activeTab: TrackerView.ProfileTab?

    let hourlyCounts: [Int]
    let ringPhase: Double
    let onLog: () -> Void
    let onUndo: () -> Void

    // live time
    @State private var now = Date()
    private let clock = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // progress bar scaling
    private let barMaxCount: Int = 20

    var body: some View {
        ZStack {
            // background stays constant
            MeshGradientView()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.35).ignoresSafeArea())

            ScrollView {
                VStack(spacing: 22) {
                    header

                    GlassCard { todayCard }
                    GlassCard { distributionCard }

                    footerNote
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
        }
        .navigationBarHidden(true)
        .onReceive(clock) { now = $0 }
        .safeAreaInset(edge: .bottom) {
            BigLogBar(title: "Log", systemImage: "plus.circle.fill", onTap: onLog)
                .padding(.horizontal, 14)
                .padding(.bottom, 10)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 4) {
                Text(patientName.isEmpty ? "Tracker" : patientName)
                    .foregroundColor(.white.opacity(0.95))
                    .font(.headline)

                Text(now.formatted(date: .abbreviated, time: .shortened))
                    .foregroundColor(.white.opacity(0.70))
                    .font(.caption)
            }

            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
    }

    // MARK: - Today card (count + vertical bar)

    private var todayCard: some View {
        let progress = min(1.0, Double(todayCount) / Double(max(1, barMaxCount)))

        return VStack(alignment: .leading, spacing: 14) {
            Text("Today")
                .font(.headline)
                .foregroundColor(.white.opacity(0.92))

            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(todayCount)")
                        .font(.system(size: 58, weight: .bold))
                        .foregroundColor(.white)

                    Text("seizures")
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                GrowingCenterBar(progress: progress)
                    .frame(width: 28, height: 70)
            }

            Button(action: onUndo) {
                Label("Undo last", systemImage: "arrow.uturn.left")
            }
            .buttonStyle(.bordered)
            .tint(.white.opacity(0.92))
            .foregroundColor(.purple)
        }
    }

    // MARK: - Distribution card (donut ring)

    private var distributionCard: some View {
        let maxPerHour = max(1, hourlyCounts.max() ?? 1)
        let t = ringPhase
        let hue = 0.62 + 0.12 * sin(t)          // smoothly oscillates
        let sat = 0.80 + 0.10 * sin(t + 1.2)
        let bri = 0.92 + 0.06 * sin(t + 2.4)

        let barColor = Color(
            hue: hue.truncatingRemainder(dividingBy: 1),
            saturation: max(0, min(1, sat)),
            brightness: max(0, min(1, bri))
        )

        return VStack(alignment: .leading, spacing: 12) {
            Text("Today distribution")
                .font(.headline)
                .foregroundColor(.white.opacity(0.92))

            HStack(spacing: 16) {
                DonutRadialBarRingWithClockLabels(
                    values: hourlyCounts,
                    maxValue: maxPerHour,
                    barColor: barColor
                )
                .frame(width: 220, height: 220)

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(todayCount)")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundColor(.white)

                    Text("logs today")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.75))

                    Text("All-time: \(totalCount)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.75))
                }

                Spacer()
            }
        }
    }

    private var footerNote: some View {
        Text("This is a personal tracker and does not provide medical advice.")
            .font(.footnote)
            .foregroundColor(.white.opacity(0.65))
            .multilineTextAlignment(.center)
            .padding(.top, 6)
            .padding(.bottom, 10)
    }
}

// MARK: - Big bottom Log button

struct BigLogBar: View {
    let title: String
    let systemImage: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .semibold))
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .shadow(radius: 12, y: 6)
    }
}

// MARK: - Vertical progress bar

struct GrowingCenterBar: View {
    /// 0...1
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            let w = geo.size.width
            let filled = max(0, min(1, progress)) * h

            ZStack(alignment: .bottom) {
                Capsule()
                    .fill(.white.opacity(0.12))
                    .frame(width: w, height: h)

                Capsule()
                    .fill(.white.opacity(0.85))
                    .frame(width: w, height: filled)
            }
            .overlay(Capsule().stroke(.white.opacity(0.20), lineWidth: 1))
        }
    }
}

// MARK: - Donut ring where bars grow inside ring thickness

struct DonutRadialBarRing: View {
    let values: [Int]
    let maxValue: Int
    var barColor: Color = .white

    var ringWidthRatio: CGFloat = 0.22
    var baseRingOpacity: Double = 0.22
    var barFillOpacity: Double = 0.85
    var outlineOpacity: Double = 0.35
    var gapRatio: CGFloat = 0.10

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            let n = max(values.count, 1)
            let step = (2.0 * Double.pi) / Double(n)
            let gap = CGFloat(step) * gapRatio

            let ringW = max(10, size * ringWidthRatio)
            let outerR = (size / 2) - 2
            let innerR = max(0, outerR - ringW)

            Canvas { context, _ in
                // base ring
                var base = Path()
                base.addArc(
                    center: center,
                    radius: (innerR + outerR) / 2,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360),
                    clockwise: false
                )
                context.stroke(
                    base,
                    with: .color(.white.opacity(baseRingOpacity)),
                    style: StrokeStyle(lineWidth: ringW, lineCap: .butt)
                )

                // bars inside ring thickness
                for i in 0..<n {
                    let v = i < values.count ? values[i] : 0
                    let t = CGFloat(v) / CGFloat(max(1, maxValue))

                    let barInner = innerR
                    let barOuter = innerR + (outerR - innerR) * t

                    let a0 = CGFloat(Double(i) * step) - .pi/2 + gap/2
                    let a1 = CGFloat(Double(i + 1) * step) - .pi/2 - gap/2

                    var wedge = Path()
                    wedge.move(to: CGPoint(x: center.x + barInner * cos(a0), y: center.y + barInner * sin(a0)))
                    wedge.addLine(to: CGPoint(x: center.x + barOuter * cos(a0), y: center.y + barOuter * sin(a0)))
                    wedge.addLine(to: CGPoint(x: center.x + barOuter * cos(a1), y: center.y + barOuter * sin(a1)))
                    wedge.addLine(to: CGPoint(x: center.x + barInner * cos(a1), y: center.y + barInner * sin(a1)))
                    wedge.closeSubpath()

                    if v > 0 {
                        context.fill(wedge, with: .color(barColor.opacity(barFillOpacity)))
                    }

                    context.stroke(wedge, with: .color(.white.opacity(outlineOpacity)), lineWidth: 1)
                }
            }
        }
    }
}

// MARK: - Wrapper with labels 12 / 3 / 6 / 9

struct DonutRadialBarRingWithClockLabels: View {
    let values: [Int]
    let maxValue: Int
    var barColor: Color = .white

    var body: some View {
        ZStack {
            DonutRadialBarRing(values: values, maxValue: maxValue, barColor: barColor)
            ClockRingLabels().allowsHitTesting(false)
        }
    }
}

struct ClockRingLabels: View {
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = size * 0.53

            ZStack {
                label("12", at: point(center: center, radius: radius, angleDeg: -90))
                label("3",  at: point(center: center, radius: radius, angleDeg:   0))
                label("6",  at: point(center: center, radius: radius, angleDeg:  90))
                label("9",  at: point(center: center, radius: radius, angleDeg: 180))
            }
        }
    }

    private func label(_ text: String, at p: CGPoint) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundColor(.white.opacity(0.85))
            .position(p)
    }

    private func point(center: CGPoint, radius: CGFloat, angleDeg: Double) -> CGPoint {
        let a = CGFloat(angleDeg) * .pi / 180
        return CGPoint(
            x: center.x + radius * cos(a),
            y: center.y + radius * sin(a)
        )
    }
}
