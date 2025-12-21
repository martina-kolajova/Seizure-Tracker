//import SwiftUI

// Change color to dark
// save times of the seizures for stats





import SwiftUI


struct TrackerView: View {
    let patientName: String
    let onBack: () -> Void



    @State private var todayCount: Int = 0
    @State private var totalCount: Int = 0
    @State private var hourlyCounts: [Int] = Array(repeating: 0, count: 12)
    @State private var violetPhase: Double = 0

    //@State private var ringPhase: Double = 0
    @State private var loggedBins: [Int] = []
    
    
    enum ProfileTab: String, Identifiable {
        case personal, diagnosis, medication
        var id: String { rawValue }
    }

    @State private var activeTab: ProfileTab? = nil

    var body: some View {
        NavigationStack {
            TrackerLayout(
                patientName: patientName,
                onBack: onBack,
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

    // was 24


    private func logNow() {
        // which hour bin (12-hour ring)
        let hour12 = Calendar.current.component(.hour, from: Date()) % 12

        todayCount += 1
        totalCount += 1
        hourlyCounts[hour12] += 1

        // remember it so undo works
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

        // optional: lighten a bit when undo
        withAnimation(.easeInOut(duration: 0.6)) {
            violetPhase = max(0, violetPhase - 0.04)
        }
    }


    @ViewBuilder
    private func profileSheet(_ tab: ProfileTab) -> some View {
        switch tab {
        case .personal:
            ZStack {
                MeshGradientView().ignoresSafeArea()
                Form {
                    Section("Personal info") { Text("Coming from profile…") }
                }
                .scrollContentBackground(.hidden)
            }

        case .diagnosis:
            PatientDelegate(
                patientName: .constant(patientName),
                onContinue: { },
                onBack: { },
                initialSection: .diagnosis
            )

        case .medication:
            PatientDelegate(
                patientName: .constant(patientName),
                onContinue: { },
                onBack: { },
                initialSection: .medication
            )
        }
    }
}

#Preview {
    TrackerView(patientName: "Martina", onBack: {})
}
