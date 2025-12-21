//
//  TrackerLayout.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 18.12.2025.
//
import SwiftUI

struct TrackerLayout: View {
    let patientName: String
    let onBack: () -> Void

    @Binding var todayCount: Int
    @Binding var totalCount: Int
    @Binding var activeTab: TrackerView.ProfileTab?
 

    
    let hourlyCounts: [Int]
    
    let onLog: () -> Void
    let onUndo: () -> Void
    
     // drives brightness/saturation
    let violetPhase: Double


    // live time
    @State private var now = Date()
    private let clock = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // progress bar scaling
    private let barMaxCount: Int = 20
    // store the hour-bin of each log so undo is correct
   

    // MARK: - Today context state

    @State private var mood: MoodChoice = .ok
    @State private var sleep: SleepChoice = .ok
    @State private var stress: StressChoice = .medium

    @State private var triggers: Set<TriggerChoice> = []

    @State private var medsTaken: Bool = true
    @State private var rescueUsed: Bool = false
    @State private var injury: Bool = false

   
    @State private var note: String = ""

    var body: some View {
        ZStack {
            // background stays constant
            MeshGradientView()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.35).ignoresSafeArea())

            ScrollView {
                VStack(spacing: 22) {
                    header

                    GlassCard { distributionCard }
                    GlassCard {
                        TodayCard(
                                todayCount: $todayCount,
                                mood: $mood,
                                sleep: $sleep,
                                stress: $stress,
                                triggers: $triggers,
                                medsTaken: $medsTaken,
                                rescueUsed: $rescueUsed,
                                injury: $injury,
                                note: $note,
                                onUndoLast: onUndo,
                                onAddSeizure: onLog
                            )
                    }

                    
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
        }
        .navigationBarHidden(true)
        .onReceive(clock) { now = $0 }
        .safeAreaInset(edge: .bottom) {
            BigLogBar(onTap: onLog)

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
    

        let p = max(0, min(1, violetPhase))

        let hue: Double = 0.78                 // violet
        let saturation = 0.35 + 0.50 * p       // starts low (pastel), gets richer
        let brightness = 0.98 - 0.45 * p       // starts very bright, gets darker

        let barColor = Color(hue: hue, saturation: saturation, brightness: brightness)


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

            }
        }
    }
}

// MARK: - Big bottom Log button

struct BigLogBar: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image("logo-white")
                .resizable()
                .scaledToFit()
                .padding(1)
                .frame(width: 204, height: 204) // ✅ square
                .foregroundColor(.white)       // (safe even for asset; no harm)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .shadow(radius: 12, y: 6)
        .accessibilityLabel("Log")
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
                
                for i in 0..<n {
                    let v = i < values.count ? values[i] : 0
                    let t = CGFloat(v) / CGFloat(max(1, maxValue))
                    if v <= 0 { continue }

                    // center the bar on the hour tick
                    let centerAngle = CGFloat(Double(i) * step) - .pi / 2
                    let barWidth = CGFloat(step) * 0.78     // angular width
                    let a0 = centerAngle - barWidth / 2
                    let a1 = centerAngle + barWidth / 2

                    // grow radially inside ring thickness
                    let r0 = innerR
                    let r1 = innerR + (outerR - innerR) * t

                    // rounded corners size
                    let corner = max(2, (outerR - innerR) * 0.18)

                    // Build a “ring segment” (annular sector) from r0..r1, then round its corners by stroking+filling
                    var seg = Path()

                    // outer arc (at r1)
                    seg.addArc(center: center,
                               radius: r1,
                               startAngle: Angle(radians: Double(a0)),
                               endAngle: Angle(radians: Double(a1)),
                               clockwise: false)

                    // inner arc (at r0) back
                    seg.addArc(center: center,
                               radius: r0,
                               startAngle: Angle(radians: Double(a1)),
                               endAngle: Angle(radians: Double(a0)),
                               clockwise: true)

                    seg.closeSubpath()

                    // ✅ Fill
                    context.fill(seg, with: .color(barColor.opacity(barFillOpacity)))

                    // ✅ Outline (greyish)
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


#Preview {
    TrackerView(patientName: "Martina", onBack: {})
}
