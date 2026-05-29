//
//  ReportView.swift
//  Seizure Tracker
//
//  Pure layout. All stats/formatting live in ReportViewModel.
//

import SwiftUI
import Charts

struct ReportView: View {
    @StateObject private var vm: ReportViewModel
    var onClose: () -> Void

    init(store: EpiLogStore, shareText: String, onClose: @escaping () -> Void = {}) {
        _vm = StateObject(wrappedValue: ReportViewModel(store: store, shareText: shareText))
        self.onClose = onClose
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    headerCard
                    kpiRow
                    weeklyChartCard
                    hourChartCard
                    trendCard
                    recentCard
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: "#F5F3FF"), Color(hex: "#EFF6FF")],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { onClose() }
                }
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: vm.shareText) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }

    // MARK: - Header
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PATIENT")
                .font(.system(size: 10, weight: .semibold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.75))
            Text(vm.patientName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 8) {
                Image(systemName: "waveform.path.ecg")
                if let code = vm.diagnosisCode {
                    Text(code)
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color.white.opacity(0.22))
                        .clipShape(Capsule())
                } else {
                    Text("No diagnosis")
                }
                Spacer()
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white.opacity(0.92))
            .padding(.top, 4)

            HStack {
                Label("\(vm.totalCount) total seizures", systemImage: "sum")
                Spacer()
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white.opacity(0.92))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color(hex: "#A855F7"), Color(hex: "#3B82F6")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }

    // MARK: - KPI Row
    private var kpiRow: some View {
        HStack(spacing: 12) {
            KPICard(value: "\(vm.weekTotal)",
                    label: "This week",
                    icon: "calendar",
                    tint: Color(hex: "#A855F7"))
            KPICard(value: vm.weeklyAverageDisplay,
                    label: "Daily avg",
                    icon: "chart.bar.fill",
                    tint: Color(hex: "#3B82F6"))
            KPICard(value: "\(vm.daysSeizureFreeThisWeek)",
                    label: "Seizure-free",
                    icon: "checkmark.seal.fill",
                    tint: Color(hex: "#10B981"))
        }
    }

    // MARK: - Weekly chart
    private var weeklyChartCard: some View {
        DashboardCard(title: "Last 7 days", subtitle: "Seizures per day") {
            Chart(vm.last7DaysCounts) { item in
                BarMark(
                    x: .value("Day", item.date, unit: .day),
                    y: .value("Count", item.count),
                    width: .ratio(0.55)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "#A855F7"), Color(hex: "#3B82F6")],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .cornerRadius(6)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                        .font(.system(size: 11, weight: .medium))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine().foregroundStyle(Color.gray.opacity(0.15))
                    AxisValueLabel().font(.system(size: 10))
                }
            }
            .frame(height: 180)
        }
    }

    // MARK: - Hour distribution
    private var hourChartCard: some View {
        DashboardCard(title: "Time of day", subtitle: "All-time distribution") {
            Chart(vm.hourBuckets) { bucket in
                BarMark(
                    x: .value("Hour", bucket.label),
                    y: .value("Count", bucket.count),
                    width: .ratio(0.6)
                )
                .foregroundStyle(Color(hex: "#5B7FE8"))
                .cornerRadius(5)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine().foregroundStyle(Color.gray.opacity(0.15))
                    AxisValueLabel().font(.system(size: 10))
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel().font(.system(size: 10, weight: .medium))
                }
            }
            .frame(height: 160)
        }
    }

    // MARK: - 30-day trend
    private var trendCard: some View {
        DashboardCard(title: "30-day trend", subtitle: "\(vm.monthTotal) total this month") {
            Chart(vm.last30DaysCounts) { item in
                AreaMark(
                    x: .value("Day", item.date),
                    y: .value("Count", item.count)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "#A855F7").opacity(0.45),
                                 Color(hex: "#A855F7").opacity(0.05)],
                        startPoint: .top, endPoint: .bottom
                    )
                )

                LineMark(
                    x: .value("Day", item.date),
                    y: .value("Count", item.count)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(Color(hex: "#A855F7"))
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                    AxisValueLabel(format: .dateTime.day().month(.narrow))
                        .font(.system(size: 10))
                    AxisGridLine().foregroundStyle(Color.gray.opacity(0.12))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine().foregroundStyle(Color.gray.opacity(0.15))
                    AxisValueLabel().font(.system(size: 10))
                }
            }
            .frame(height: 160)
        }
    }

    // MARK: - Recent events
    private var recentCard: some View {
        DashboardCard(title: "Recent events", subtitle: "Last \(vm.recentEvents.count) entries") {
            if vm.recentEvents.isEmpty {
                Text("No seizures logged yet.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(vm.recentEvents.enumerated()), id: \.element.id) { idx, ev in
                        EventRow(event: ev)
                        if idx < vm.recentEvents.count - 1 {
                            Divider().padding(.leading, 36)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Reusable view atoms (pure presentation)

private struct DashboardCard<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

private struct KPICard: View {
    let value: String
    let label: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(tint)
                .clipShape(Circle())
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

private struct EventRow: View {
    let event: SeizureEvent

    private static let df: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#A855F7"), Color(hex: "#3B82F6")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 8, height: 8)
                .padding(.leading, 4)
            Text(Self.df.string(from: event.date))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
            Spacer()
            Text(String(format: "%.0f%%", event.tintPhase * 100))
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Color.gray.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    ReportView(store: EpiLogStore(), shareText: "Sample report")
}
