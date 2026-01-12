//
//  CalendarStrip.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 03.01.2026.

// CalendarStrip is a reusable SwiftUI component that displays a week-based calendar
// and exposes the selected date via a binding, keeping date logic internal and the parent view in control of state



import SwiftUI

/// Weekly calendar strip with selectable days.
struct CalendarStrip: View {

    /// Selected date controlled by parent view.
    @Binding var selectedDate: Date

    // MARK: - Derived state

    private var selected: Date { selectedDate }
    private var selectedDayKey: Date {
        Calendar.current.startOfDay(for: selected)
    }
    private var dates: [Date] {
        weekDates(around: selected)
    }

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(spacing: 10) {
                Image(systemName: "calendar")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))

                Text(monthTitle(selected))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.95))

                Spacer()

                Button {
                    selectedDate = Date()
                } label: {
                    Text("Today")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.16), in: Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.20), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 8) {
                ForEach(dates, id: \.self) { date in
                    let isSelected = isSameDay(date, selectedDayKey)

                    Button {
                        selectedDate = date
                    } label: {
                        VStack(spacing: 6) {
                            Text(dayLabel(date))
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(
                                    .white.opacity(isSelected ? 1.0 : 0.65)
                                )

                            Text(dayNumber(date))
                                .font(.callout.weight(.bold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 34)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(.white.opacity(isSelected ? 0.22 : 0.10))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(.white.opacity(isSelected ? 0.35 : 0.18), lineWidth: 1)
                                )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        )
    }

    // MARK: - Date helpers

    private func weekDates(around date: Date) -> [Date] {
        let cal = Calendar.current
        let dayKey = cal.startOfDay(for: date)
        let weekday = cal.component(.weekday, from: dayKey)

        let mondayOffset = (weekday + 5) % 7
        let monday = cal.date(byAdding: .day, value: -mondayOffset, to: dayKey) ?? dayKey

        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: monday) }
    }

    private func dayLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "EEE"
        return f.string(from: date).uppercased()
    }

    private func dayNumber(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "d"
        return f.string(from: date)
    }

    private func monthTitle(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }

    private func isSameDay(_ a: Date, _ b: Date) -> Bool {
        Calendar.current.isDate(a, inSameDayAs: b)
    }
}
