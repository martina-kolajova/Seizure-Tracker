//
//  DonutRadialBarRing.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 03.01.2026.
//


import SwiftUI

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

                for i in 0..<n {
                    let v = i < values.count ? values[i] : 0
                    let t = CGFloat(v) / CGFloat(max(1, maxValue))
                    if v <= 0 { continue }

                    let centerAngle = CGFloat(Double(i) * step) - .pi / 2
                    let barWidth = CGFloat(step) * 0.78
                    let a0 = centerAngle - barWidth / 2
                    let a1 = centerAngle + barWidth / 2

                    let inset: CGFloat = 0.8
                    let r0 = innerR + inset
                    let r1 = outerR - inset


                    var seg = Path()
                    seg.addArc(center: center,
                               radius: r1,
                               startAngle: Angle(radians: Double(a0)),
                               endAngle: Angle(radians: Double(a1)),
                               clockwise: false)

                    seg.addArc(center: center,
                               radius: r0,
                               startAngle: Angle(radians: Double(a1)),
                               endAngle: Angle(radians: Double(a0)),
                               clockwise: true)

                    seg.closeSubpath()

                    context.fill(seg, with: .color(barColor.opacity(barFillOpacity)))
                    context.stroke(seg, with: .color(.white.opacity(outlineOpacity)), lineWidth: 1)
                }
            }
        }
    }
}

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
