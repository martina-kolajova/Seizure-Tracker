//
//  TrackerLayout 2.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 03.01.2026.

import SwiftUI



struct TrackerLayout: View {

    @ObservedObject var vm: TrackerViewModel
    //   view does not own the ViewModel, but it observes it and re-renders whenever the ViewModel changes.
    
    let patientName: String
    let onBack: () -> Void
    
    
    var body: some View {
        ZStack {
            // Shared linear gradient — same as patient-info screens.
            AppGradient()
                .overlay(Color.black.opacity(0.25).ignoresSafeArea())

            ScrollView {
                VStack(spacing: 22) {
                    header
                    topTabBar
                    calendarStrip

                    Group {
                        if vm.selectedTab == .tracker {
                            VStack(spacing: 16) {
                                GlassCard { distributionCard }

                                // Log button directly below the distribution
                                VStack(spacing: 8) {
                                    Text("Tap to log a seizure")
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(.white.opacity(0.85))

                                    BigLogBar(onTap: { vm.logSeizure() })
                                }
                                .padding(.top, 4)
                            }
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                        } else {
                            GlassCard {
                                DailyStatus(
                                    todayCount: vm.todayCount,
                                    mood: $vm.mood,
                                    sleep: $vm.sleep,
                                    stress: $vm.stress,
                                    triggers: $vm.triggers,
                                    medsTaken: $vm.medsTaken,
                                    rescueUsed: $vm.rescueUsed,
                                    injury: $vm.injury,
                                    note: $vm.note,
                                    onUndoLast: { vm.undoLast() },
                                    onGenerateReport: { vm.openReport() }
                                )
                            }
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                        }
                    }
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.9),
                        value: vm.selectedTab
                    )
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
        }
        .navigationBarHidden(true)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 60)
        }
        .animation(
            .spring(response: 0.4, dampingFraction: 0.9),
            value: vm.selectedTab
        )
        .onAppear {
            vm.syncCounts()
        }
        .onChange(of: vm.selectedDate) { _ in
            vm.onSelectedDateChanged()

        }
    }
}


#Preview {
    let store = EpiLogStore()
    let vm = TrackerViewModel(store: store)

    return TrackerLayout(
        vm: vm,
        patientName: "Anna Novakova",
        onBack: {}
    )
}
