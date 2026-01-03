//import SwiftUI

// Change color to dark
// save times of the seizures for stats

import SwiftUI


struct TrackerView: View {
    let patientName: String
    let onBack: () -> Void
    

    @ObservedObject var store: EpiLogStore

    @State private var todayCount: Int = 0
    @State private var totalCount: Int = 0
    @State private var hourlyCounts: [Int] = Array(repeating: 0, count: 12)
    @State private var violetPhase: Double = 0
    @State private var loggedBins: [Int] = []

    enum ProfileTab: String, Identifiable {
        case personal, diagnosis, medication
        var id: String { rawValue }
    }
    @State private var activeTab: ProfileTab? = nil
    
    private func generateReport() {
        let p = store.patient
        print("📄 REPORT")
        print("Name:", p.firstName, p.lastName)
        print("Diagnosis:", p.diagnosisText)
        print("Medication:", p.medicationText)
        print("Today count:", todayCount, "Total:", totalCount)
    }


    var body: some View {
        NavigationStack {
            TrackerLayout(
                store: store,                 // ✅ FIX (was missing)
                patientName: patientName,
                onBack: onBack,
                onGenerateReport: generateReport,
                todayCount: $todayCount,
                totalCount: $totalCount,
                activeTab: $activeTab,
                hourlyCounts: hourlyCounts,
                onLog: logNow,
                onUndo: undoLastSimple,
                violetPhase: violetPhase
            )
            .sheet(item: $activeTab) { tab in
                profileSheet(tab)
            }
        }
    }

    private func logNow() {
        let hour12 = Calendar.current.component(.hour, from: Date()) % 12

        todayCount += 1
        totalCount += 1
        hourlyCounts[hour12] += 1
        loggedBins.append(hour12)

        withAnimation(.easeInOut(duration: 1.2)) {
            violetPhase = min(violetPhase + 0.06, 1.0)
        }
    }

    private func undoLastSimple() {
        guard let lastBin = loggedBins.popLast() else { return }

        if todayCount > 0 { todayCount -= 1 }
        if totalCount > 0 { totalCount -= 1 }

        if (0..<hourlyCounts.count).contains(lastBin) {
            hourlyCounts[lastBin] = max(0, hourlyCounts[lastBin] - 1)
        }

        withAnimation(.easeInOut(duration: 0.6)) {
            violetPhase = max(0, violetPhase - 0.04)
        }
    }

    @ViewBuilder
    private func profileSheet(_ tab: ProfileTab) -> some View {
        PatientDelegate(
            store: store,
            onBack: { activeTab = nil },
            onContinue: { activeTab = nil }
        )
    }
}

#Preview {
    TrackerView(
        patientName: "Martina",
        onBack: {},
        store: EpiLogStore()
    )
}

