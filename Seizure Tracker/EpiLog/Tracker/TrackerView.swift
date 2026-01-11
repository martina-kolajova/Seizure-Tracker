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

    // MARK: - Profile tabs
    enum ProfileTab: String, Identifiable {
        case personal, diagnosis, medication
        var id: String { rawValue }
    }

    // MARK: - Sheet routing 
    enum SheetRoute: Identifiable {
        case profile(ProfileTab)
        case report(String)

        var id: String {
            switch self {
            case .profile(let tab):
                return "profile-\(tab.rawValue)"
            case .report:
                return "report"
            }
        }
    }

    @State private var sheetRoute: SheetRoute?

    // MARK: - Report generation
    private func generateReport() {
        let p = store.patient

        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short

        var lines: [String] = []
        lines.append("📄 Seizure Report")
        lines.append("")
        lines.append("Patient: \(p.firstName) \(p.lastName)")
        lines.append("Diagnosis: \(p.diagnosisText.isEmpty ? "—" : p.diagnosisText)")
        lines.append("Medication: \(p.medicationText.isEmpty ? "—" : p.medicationText)")
        lines.append("")
        lines.append("Total seizures: \(store.seizures.count)")
        lines.append("")

        if store.seizures.isEmpty {
            lines.append("No seizures logged.")
        } else {
            lines.append("Seizure timestamps:")
            for (i, ev) in store.seizures.enumerated() {
                lines.append("\(i + 1). \(df.string(from: ev.date))")
            }
        }

        sheetRoute = .report(lines.joined(separator: "\n"))
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            TrackerLayout(
                store: store,
                patientName: patientName,
                onBack: onBack,
                onGenerateReport: generateReport,
                todayCount: $todayCount,
                totalCount: $totalCount,
                activeTab: .constant(nil), // no longer used directly
                violetPhase: $violetPhase
            )
            .sheet(item: $sheetRoute) { route in
                switch route {

                case .profile(_):
                    PatientDelegate(
                        store: store,
                        onBack: { sheetRoute = nil },
                        onContinue: { sheetRoute = nil }
                    )

                case .report(let text):
                    ReportView(text: text)
                }
            }
        }
    }
}

#Preview {
    TrackerView(
        patientName: "Anna Novakova",
        onBack: {},
        store: EpiLogStore()
    )
}



