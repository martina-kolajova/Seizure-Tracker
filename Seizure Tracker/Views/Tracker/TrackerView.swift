//import SwiftUI

// Change color to dark
// save times of the seizures for stats





import SwiftUI
import SwiftUI

struct TrackerView: View {
    let patientName: String
    let onBack: () -> Void



    @State private var todayCount: Int = 0
    @State private var totalCount: Int = 0
    @State private var hourlyCounts: [Int] = Array(repeating: 0, count: 12)
    @State private var violetPhase: Double = 0

    //@State private var ringPhase: Double = 0

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
                hourlyCounts: hourlyCounts,// or
                onLog: logNow,
                onUndo: undoLastSimple,
                violetPhase: violetPhase,
                
            )
            .sheet(item: $activeTab) { tab in
                profileSheet(tab)
            }
        }
    }

    // was 24


    private func logNow() {
        todayCount += 1
        totalCount += 1

        let hour24 = Calendar.current.component(.hour, from: Date())
        let hour12 = hour24 % 12
        hourlyCounts[hour12] += 1

        // ✅ only darken (clamped)
        withAnimation(.easeInOut(duration: 1.2)) {
            violetPhase = min(violetPhase + 0.06, 1.0)   // slower darkenin

        }
    }


    private func undoLastSimple() {
        if todayCount > 0 { todayCount -= 1 }
        if totalCount > 0 { totalCount -= 1 }
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
