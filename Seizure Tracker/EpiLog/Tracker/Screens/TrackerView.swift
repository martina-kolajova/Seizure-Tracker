
import SwiftUI

/// Entry point for the Tracker screen.
/// - Owns the TrackerViewModel (MVVM)
/// - Coordinates navigation (sheets)
/// - Passes shared dependencies to child flows
struct TrackerView: View {

    /// Displayed patient name (UI-only value)
    let patientName: String

    /// Callback for dismissing / navigating back
    let onBack: () -> Void

    /// Shared data store (single source of truth for patient + seizures).
    /// Kept here because other flows (e.g. PatientInfoFlowView) still need it.
    @ObservedObject var store: EpiLogStore

    /// ViewModel owned by this screen.
    /// `@StateObject` ensures the VM is created once and survives view reloads.
    @StateObject private var vm: TrackerViewModel

    /// Custom initializer required because we inject `store`
    /// and must initialize `@StateObject` manually.
    init(
        patientName: String,
        onBack: @escaping () -> Void,
        store: EpiLogStore
    ) {
        self.patientName = patientName
        self.onBack = onBack
        self.store = store

        // Create the ViewModel and inject the shared store
        _vm = StateObject(wrappedValue: TrackerViewModel(store: store))
    }

    // MARK: - Profile tabs (used for sheet routing)

    /// Tabs for patient profile flow (used by sheet navigation)
    enum ProfileTab: String, Identifiable {
        case personal, diagnosis, medication
        var id: String { rawValue }
    }

    // MARK: - Sheet routing

    /// Centralized sheet routing for this screen.
    /// Keeps navigation logic out of child views.
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

    /// Current active sheet (if any)
    @State private var sheetRoute: SheetRoute?

    /// Generates report text via the ViewModel and opens the report sheet.
    /// Business logic stays in VM; the View only triggers navigation.
    private func generateReport() {
        sheetRoute = .report(vm.generateReportText())
    }

    // MARK: - View body

    var body: some View {
        NavigationStack {
            /// Main tracker layout (pure UI).
            /// Observes the ViewModel and reacts to its state.
            TrackerLayout(
                vm: vm,
                patientName: patientName,
                onBack: onBack,
                onGenerateReport: generateReport
            )
            /// Sheet-based navigation handled at the screen level
            .sheet(item: $sheetRoute) { route in
                switch route {

                /// Patient profile setup / edit flow
                case .profile:
                    PatientInfoFlowView(
                        store: store,
                        onBack: { sheetRoute = nil },
                        onContinue: { sheetRoute = nil }
                    )


                /// Generated seizure report
                case .report(let text):
                    ReportView(text: text)
                }
            }
        }
    }
}

#Preview {
    /// Preview uses a fresh store instance.
    /// ViewModel is created internally from the store.
    TrackerView(
        patientName: "Anna Novakova",
        onBack: {},
        store: EpiLogStore()
    )
}
