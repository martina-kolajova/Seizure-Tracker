//
//  TrackerLayout.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 18.12.2025.
//
import SwiftUI

//
//
//import SwiftUI
//
//struct TrackerLayout: View {
//
//    // MARK: - Top tab bar
//    private enum TopTab: String {
//        case tracker = "Tracker"
//        case daily   = "Daily Status"
//    }
//
//    @State private var selectedTab: TopTab = .tracker
//
//    
//    @ObservedObject var store: EpiLogStore
//
//    // MARK: - Inputs
//    let patientName: String
//    let onBack: () -> Void
//    let onGenerateReport: () -> Void
//
//
//    @Binding var todayCount: Int
//    @Binding var totalCount: Int
//    @Binding var activeTab: TrackerView.ProfileTab?
//
//    let hourlyCounts: [Int]
//
//    let onLog: () -> Void
//    let onUndo: () -> Void
//
//    let violetPhase: Double
//
//    // MARK: - Today context state
//    // selected day (highlighted in calendar strip)
//    @State private var selectedDate: Date = Date()
//
//    @State private var showTodayDetails = false
//
//    @State private var mood: MoodChoice = .ok
//    @State private var sleep: SleepChoice = .ok
//    @State private var stress: StressChoice = .medium
//
//    @State private var triggers: Set<TriggerChoice> = []
//
//    @State private var medsTaken: Bool = false
//    @State private var rescueUsed: Bool = false
//    @State private var injury: Bool = false
//
//    @State private var note: String = ""
//    
//    
//
//    var body: some View {
//        ZStack {
//            MeshGradientView()
//                .ignoresSafeArea()
//                .overlay(Color.black.opacity(0.4).ignoresSafeArea())
//
//            ScrollView {
//                VStack(spacing: 22) {
//                    header
//                    topTabBar
//                    calendarStrip
//
//                    Group {
//                        if selectedTab == .tracker {
//                            GlassCard { distributionCard }
//                                .transition(.opacity.combined(with: .move(edge: .leading)))
//                        } else {
//                            GlassCard {
//                                TodayCardContainer(
//                                    todayCount: $todayCount,
//                                    showDetails: $showTodayDetails,
//                                    mood: $mood,
//                                    sleep: $sleep,
//                                    stress: $stress,
//                                    triggers: $triggers,
//                                    medsTaken: $medsTaken,
//                                    rescueUsed: $rescueUsed,
//                                    injury: $injury,
//                                    note: $note,
//                                    onUndoLast: onUndo,
//                                    onAddSeizure: onLog,
//                                    onGenerateReport: onGenerateReport 
//                                )
//                            }
//                            .transition(.opacity.combined(with: .move(edge: .trailing)))
//                        }
//                    }
//                    .animation(.spring(response: 0.45, dampingFraction: 0.9), value: selectedTab)
//                }
//                .padding(.horizontal, 18)
//                .padding(.top, 16)
//                .padding(.bottom, 120)
//            }
//        }
//        .navigationBarHidden(true)
//        .safeAreaInset(edge: .bottom) {
//            if selectedTab == .tracker {
//                VStack(spacing: 6) {
//                    Text("Tap to log a seizure")
//                        .font(.caption.weight(.semibold))   // ✅ keep just one font
//                        .foregroundColor(.white.opacity(0.80))
//
//                    BigLogBar(onTap: onLog)
//                }
//                .padding(.horizontal, 14)
//                .padding(.bottom, 10)
//            } else {
//                Color.clear
//                    .frame(height: 60)
//            }
//        }
//        .animation(.spring(response: 0.4, dampingFraction: 0.9), value: selectedTab)
//    }
//
//    // MARK: - Header
//
//    private var header: some View {
//        HStack {
//            Button(action: onBack) {
//                Image(systemName: "chevron.left")
//                    .foregroundColor(.white)
//                    .padding(10)
//                    .background(.ultraThinMaterial, in: Circle())
//                    .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
//            }
//            .buttonStyle(.plain)
//
//            Spacer()
//
//            Text(patientName.isEmpty ? "Patient" : patientName)   // ✅ better fallback
//                .foregroundColor(.white.opacity(0.95))
//                .font(.headline)
//
//            Spacer()
//
//            Color.clear.frame(width: 44, height: 44)
//        }
//    }
//
//
//    // MARK: - Top tab bar
//    private var topTabBar: some View {
//        HStack(spacing: 8) {
//            segTab(.tracker)
//            segTab(.daily)
//        }
//        .padding(8)
//        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
//        .overlay(
//            RoundedRectangle(cornerRadius: 18, style: .continuous)
//                .stroke(Color.white.opacity(0.14), lineWidth: 1)
//        )
//    }
//    
//    private func segTab(_ tab: TopTab) -> some View {
//        let isOn = (selectedTab == tab)
//        
//        return Button {
//            withAnimation(.spring(response: 0.35, dampingFraction: 0.92)) {
//                selectedTab = tab
//            }
//        } label: {
//            Text(tab.rawValue)
//                .font(.subheadline.weight(.semibold))
//                .foregroundColor(.white.opacity(isOn ? 0.98 : 0.70))
//                .frame(maxWidth: .infinity)
//                .padding(.vertical, 10)
//                .background(
//                    RoundedRectangle(cornerRadius: 14, style: .continuous)
//                        .fill(isOn ? Color.white.opacity(0.18) : Color.white.opacity(0.06))
//                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 14, style: .continuous)
//                        .stroke(Color.white.opacity(isOn ? 0.22 : 0.10), lineWidth: 1)
//                )
//        }
//        .buttonStyle(.plain)
//    }
//    
//    
//   
//    // MARK: - Calendar strip (above clock bar)
//    // MARK: - Calendar strip (above clock bar)
//    private var calendarStrip: some View {
//        CalendarStrip(
//            selectedDate: $selectedDate,
//            violetPhase: violetPhase
//        )
//        .padding(.top, 8)
//    }
//
//
//    // MARK: - Distribution card (donut ring)
//    private var distributionCard: some View {
//        let maxPerHour = max(1, hourlyCounts.max() ?? 1)
//        
//        let p = max(0, min(1, violetPhase))
//        
//        let hue: Double = 0.78
//        let saturation = 0.35 + 0.50 * p
//        let brightness = 0.98 - 0.45 * p
//        
//        let barColor = Color(hue: hue, saturation: saturation, brightness: brightness)
//        
//        return VStack(alignment: .leading, spacing: 12) {
//            
//            // ✅ Title
//            VStack(alignment: .leading, spacing: 2) {
//                Text("Daily seizure distribution")
//                    .font(.subheadline.weight(.semibold))
//                    .foregroundColor(.white.opacity(0.9))
//                
//                Text("By hour")
//                    .font(.caption)
//                    .foregroundColor(.white.opacity(0.65))
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            // Chart
//            HStack {
//                   Spacer()
//
//                   DonutRadialBarRingWithClockLabels(
//                       values: hourlyCounts,
//                       maxValue: maxPerHour,
//                       barColor: barColor
//                   )
//                   .frame(width: 220, height: 220)
//
//                   Spacer()
//            }
//        }
//    }
//}
//
//
//
//// MARK: - Big bottom Log button
//
//struct BigLogBar: View {
//    let onTap: () -> Void
//
//    var body: some View {
//        Button(action: onTap) {
//            Image("logo-white")
//                .resizable()
//                .scaledToFit()
//                .padding(1)
//                .frame(width: 102, height: 102)
//                .foregroundColor(.white)
//                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 18, style: .continuous)
//                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
//                )
//        }
//        .buttonStyle(.plain)
//        .shadow(radius: 12, y: 6)
//        .accessibilityLabel("Log")
//       
//    }
//}
//
//// MARK: - Vertical progress bar
//
//struct GrowingCenterBar: View {
//    /// 0...1
//    let progress: Double
//
//    var body: some View {
//        GeometryReader { geo in
//            let h = geo.size.height
//            let w = geo.size.width
//            let filled = max(0, min(1, progress)) * h
//
//            ZStack(alignment: .bottom) {
//                Capsule()
//                    .fill(.white.opacity(0.12))
//                    .frame(width: w, height: h)
//
//                Capsule()
//                    .fill(.white.opacity(0.85))
//                    .frame(width: w, height: filled)
//            }
//            .overlay(Capsule().stroke(.white.opacity(0.20), lineWidth: 1))
//        }
//    }
//}
//
//// MARK: - Donut ring where bars grow inside ring thickness
//
//struct DonutRadialBarRing: View {
//    let values: [Int]
//    let maxValue: Int
//    var barColor: Color = .white
//
//    var ringWidthRatio: CGFloat = 0.22
//    var baseRingOpacity: Double = 0.22
//    var barFillOpacity: Double = 0.85
//    var outlineOpacity: Double = 0.35
//    var gapRatio: CGFloat = 0.10
//
//    var body: some View {
//        GeometryReader { geo in
//            let size = min(geo.size.width, geo.size.height)
//            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
//
//            let n = max(values.count, 1)
//            let step = (2.0 * Double.pi) / Double(n)
//            let _ = CGFloat(step) * gapRatio
//
//            let ringW = max(10, size * ringWidthRatio)
//            let outerR = (size / 2) - 2
//            let innerR = max(0, outerR - ringW)
//
//            Canvas { context, _ in
//                // base ring
//                var base = Path()
//                base.addArc(
//                    center: center,
//                    radius: (innerR + outerR) / 2,
//                    startAngle: .degrees(0),
//                    endAngle: .degrees(360),
//                    clockwise: false
//                )
//                context.stroke(
//                    base,
//                    with: .color(.white.opacity(baseRingOpacity)),
//                    style: StrokeStyle(lineWidth: ringW, lineCap: .butt)
//                )
//
//                for i in 0..<n {
//                    let v = i < values.count ? values[i] : 0
//                    let t = CGFloat(v) / CGFloat(max(1, maxValue))
//                    if v <= 0 { continue }
//
//                    // center the bar on the hour tick
//                    let centerAngle = CGFloat(Double(i) * step) - .pi / 2
//                    let barWidth = CGFloat(step) * 0.78
//                    let a0 = centerAngle - barWidth / 2
//                    let a1 = centerAngle + barWidth / 2
//
//                    // grow radially inside ring thickness
//                    let r0 = innerR
//                    let r1 = innerR + (outerR - innerR) * t
//
//                    // segment
//                    var seg = Path()
//                    seg.addArc(center: center,
//                               radius: r1,
//                               startAngle: Angle(radians: Double(a0)),
//                               endAngle: Angle(radians: Double(a1)),
//                               clockwise: false)
//
//                    seg.addArc(center: center,
//                               radius: r0,
//                               startAngle: Angle(radians: Double(a1)),
//                               endAngle: Angle(radians: Double(a0)),
//                               clockwise: true)
//
//                    seg.closeSubpath()
//
//                    context.fill(seg, with: .color(barColor.opacity(barFillOpacity)))
//                    context.stroke(seg, with: .color(.white.opacity(outlineOpacity)), lineWidth: 1)
//                }
//            }
//        }
//    }
//}
//
//struct DonutRadialBarRingWithClockLabels: View {
//    let values: [Int]
//    let maxValue: Int
//    var barColor: Color = .white
//
//    var body: some View {
//        ZStack {
//            DonutRadialBarRing(values: values, maxValue: maxValue, barColor: barColor)
//            ClockRingLabels().allowsHitTesting(false)
//        }
//    }
//}
//
//struct ClockRingLabels: View {
//    var body: some View {
//        GeometryReader { geo in
//            let size = min(geo.size.width, geo.size.height)
//            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
//            let radius = size * 0.53
//
//            ZStack {
//                label("12", at: point(center: center, radius: radius, angleDeg: -90))
//                label("3",  at: point(center: center, radius: radius, angleDeg:   0))
//                label("6",  at: point(center: center, radius: radius, angleDeg:  90))
//                label("9",  at: point(center: center, radius: radius, angleDeg: 180))
//            }
//        }
//    }
//
//    private func label(_ text: String, at p: CGPoint) -> some View {
//        Text(text)
//            .font(.caption.weight(.semibold))
//            .foregroundColor(.white.opacity(0.85))
//            .position(p)
//    }
//
//    private func point(center: CGPoint, radius: CGFloat, angleDeg: Double) -> CGPoint {
//        let a = CGFloat(angleDeg) * .pi / 180
//        return CGPoint(
//            x: center.x + radius * cos(a),
//            y: center.y + radius * sin(a)
//        )
//    }
//}
//
//#Preview {
//    TrackerView(
//        patientName: "Martina",
//        onBack: {},
//        store: EpiLogStore()
//    )
//}
//
