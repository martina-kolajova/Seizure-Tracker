//
//  TrackerLayout 2.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 03.01.2026.

import SwiftUI

struct TrackerLayout: View {

    // MARK: - Top tab bar
    enum TopTab: String {
        case tracker = "Tracker"
        case daily   = "Daily Status"
    }

    @State var selectedTab: TopTab = .tracker

    @ObservedObject var store: EpiLogStore

    // MARK: - Inputs
    let patientName: String
    let onBack: () -> Void
    let onGenerateReport: () -> Void

    @Binding var todayCount: Int
    @Binding var totalCount: Int
    @Binding var activeTab: TrackerView.ProfileTab?

//    let hourlyCounts: [Int]



    @Binding var violetPhase: Double


    // MARK: - Today context state
    @State var selectedDate: Date = Date()
    @State private var showTodayDetails = false

    @State private var mood: MoodChoice = .ok
    @State private var sleep: SleepChoice = .ok
    @State private var stress: StressChoice = .medium
    @State private var triggers: Set<TriggerChoice> = []

    @State private var medsTaken: Bool = false
    @State private var rescueUsed: Bool = false
    @State private var injury: Bool = false

    @State private var note: String = ""
    
    private func syncCounts() {
        todayCount = store.count(for: selectedDate)
        totalCount = store.totalCount()
    }

    private func logSeizureForSelectedDay() {
        store.addSeizure(onDay: selectedDate)
        withAnimation(.easeInOut(duration: 0.8)) {
            violetPhase = min(violetPhase + 0.08, 1.0)
        }
        syncCounts()
    }

    private func undoSeizureForSelectedDay() {
        _ = store.undoLastSeizure(onDay: selectedDate)
        withAnimation(.easeInOut(duration: 0.5)) {
            violetPhase = max(violetPhase - 0.06, 0.0)
        }
        syncCounts()
    }


    var body: some View {
        ZStack {
            MeshGradientView()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.4).ignoresSafeArea())

            ScrollView {
                VStack(spacing: 22) {
                    header
                    topTabBar
                    calendarStrip

                    Group {
                        if selectedTab == .tracker {
                            GlassCard { distributionCard }
                                .transition(.opacity.combined(with: .move(edge: .leading)))
                        } else {
                            GlassCard {
                                TodayCardContainer(
                                    todayCount: $todayCount,
                                    showDetails: $showTodayDetails,
                                    mood: $mood,
                                    sleep: $sleep,
                                    stress: $stress,
                                    triggers: $triggers,
                                    medsTaken: $medsTaken,
                                    rescueUsed: $rescueUsed,
                                    injury: $injury,
                                    note: $note,
                                    onUndoLast: undoSeizureForSelectedDay,
                                    onAddSeizure: logSeizureForSelectedDay,

                                    onGenerateReport: onGenerateReport
                                )
                            }
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                        }
                    }
                    .animation(.spring(response: 0.45, dampingFraction: 0.9), value: selectedTab)
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
        }
        .navigationBarHidden(true)
        .safeAreaInset(edge: .bottom) {
            if selectedTab == .tracker {
                VStack(spacing: 6) {
                    Text("Tap to log a seizure")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white.opacity(0.80))

                    BigLogBar(onTap: logSeizureForSelectedDay)

                }
                .padding(.horizontal, 14)
                .padding(.bottom, 10)
            } else {
                Color.clear.frame(height: 60)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.9), value: selectedTab)
        .onAppear { syncCounts() }
        .onChange(of: selectedDate) { _ in syncCounts() }
        .onChange(of: store.seizures.count) { _ in syncCounts() }

    }
}


#Preview {
    TrackerView(
        patientName: "Martina",
        onBack: {},
        store: EpiLogStore()
    )
}
