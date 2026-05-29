import SwiftUI

/// Thin shell: owns the VM, hands work to TrackerLayout, presents sheets driven
/// by the VM's `sheetRoute`. No business or routing logic here.
struct TrackerView: View {

    let patientName: String
    let onBack: () -> Void

    /// Shared data store. Kept here so it can be re-injected into sheet content
    /// (PatientInfoFlowView, ReportView) without going through the VM.
    @ObservedObject var store: EpiLogStore

    @StateObject private var vm: TrackerViewModel

    init(
        patientName: String,
        onBack: @escaping () -> Void,
        store: EpiLogStore
    ) {
        self.patientName = patientName
        self.onBack = onBack
        self.store = store
        _vm = StateObject(wrappedValue: TrackerViewModel(store: store))
    }

    var body: some View {
        NavigationStack {
            TrackerLayout(
                vm: vm,
                patientName: patientName,
                onBack: onBack
            )
            .sheet(item: $vm.sheetRoute) { route in
                switch route {
                case .profile:
                    PatientInfoFlowView(
                        store: store,
                        onBack: { vm.closeSheet() },
                        onContinue: { vm.closeSheet() }
                    )
                case .report(let text):
                    ReportView(
                        store: store,
                        shareText: text,
                        onClose: { vm.closeSheet() }
                    )
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
