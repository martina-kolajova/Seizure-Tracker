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
    
    var currentColor: Color = .purple   // 👈 color for current bin
    var currentIndex: Int? = nil         // 👈 index to recolor
    var perBinColors: [Color]? = nil


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

                // opacity mapping: same color, different intensity
                let denom = CGFloat(max(1, maxValue))
                let minSegOpacity: Double = 0.15

                for i in 0..<n {
                    let v = i < values.count ? values[i] : 0
                    if v <= 0 { continue }

                    let t = CGFloat(v) / denom
                    let clampedT = min(max(t, 0), 1)

                    let opacity = minSegOpacity + Double(clampedT) * (barFillOpacity - minSegOpacity)

//                    let centerAngle = CGFloat(Double(i) * step) - .pi / 2
                    let centerAngle = CGFloat((Double(i) + 0.5) * step) - .pi / 2

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

                    let baseColor = perBinColors?[safe: i] ?? barColor

                    let fillColor =
                        (currentIndex == i)
                            ? currentColor
                            : baseColor


                    context.fill(
                        seg,
                        with: .color(fillColor.opacity(opacity))
                    )

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

    var currentColor: Color = .purple
    var currentIndex: Int? = nil
    var perBinColors: [Color]? = nil


    var body: some View {
        ZStack {
            DonutRadialBarRing(
                values: values,
                maxValue: maxValue,
                barColor: barColor,
                currentColor: currentColor,
                currentIndex: currentIndex,
                perBinColors: perBinColors
            )
            ClockRingLabels().allowsHitTesting(false)
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
