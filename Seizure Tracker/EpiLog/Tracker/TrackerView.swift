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
    @State private var violetPhase: Double = 0
   //  jen pro  tutu obrazovku

    
    enum ProfileTab: String, Identifiable {
        case personal, diagnosis, medication
        var id: String { rawValue }
    }
    @State private var activeTab: ProfileTab? = nil
    
    private func generateReport() {
        let p = store.patient

        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short

        print("📄 SEIZURE REPORT")
        print("Patient: \(p.firstName) \(p.lastName)")
        print("Diagnosis: \(p.diagnosisText.isEmpty ? "—" : p.diagnosisText)")
        print("Medication: \(p.medicationText.isEmpty ? "—" : p.medicationText)")
        print("")

        print("Total seizures: \(store.seizures.count)")
        if store.seizures.isEmpty {
            print("No seizures logged.")
            return
        }

        print("Seizure timestamps:")
        for (i, ev) in store.seizures.enumerated() {
            print("\(i + 1). \(df.string(from: ev.date))")
        }
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
                violetPhase: $violetPhase
            )
            .sheet(item: $activeTab) { tab in
                profileSheet(tab)
            }
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

