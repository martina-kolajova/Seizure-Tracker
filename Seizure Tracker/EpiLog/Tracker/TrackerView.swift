




import SwiftUI


struct TrackerView: View {
    let patientName: String
    let onBack: () -> Void

    @ObservedObject var store: EpiLogStore          // ✅ add back
    
    //
    @StateObject private var vm: TrackerViewModel
    

    init(patientName: String, onBack: @escaping () -> Void, store: EpiLogStore) {
        self.patientName = patientName
        self.onBack = onBack
        self.store = store                          // ✅ keep store
        _vm = StateObject(wrappedValue: TrackerViewModel(store: store))
    }

    enum ProfileTab: String, Identifiable {
        case personal, diagnosis, medication
        var id: String { rawValue }
    }

    enum SheetRoute: Identifiable {
        case profile(ProfileTab)
        case report(String)

        var id: String {
            switch self {
            case .profile(let tab): return "profile-\(tab.rawValue)"
            case .report: return "report"
            }
        }
    }

    @State private var sheetRoute: SheetRoute?

    private func generateReport() {
        sheetRoute = .report(vm.generateReportText())
    }

    var body: some View {
        NavigationStack {
            TrackerLayout(
                vm: vm,
                patientName: patientName,
                onBack: onBack,
                onGenerateReport: generateReport
            )
            .sheet(item: $sheetRoute) { route in
                switch route {
                case .profile:
                    PatientDelegate(
                        store: store,              // ✅ works again
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



