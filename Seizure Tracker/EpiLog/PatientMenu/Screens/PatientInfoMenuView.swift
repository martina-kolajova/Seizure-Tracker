//
//  PatientInfoMenuView.swift
//  Seizure Tracker
//
//  Pure layout. Geometry math and gesture decisions live in
//  PatientInfoMenuViewModel.
//

import SwiftUI

struct PatientInfoMenuView: View {
    let onBack: () -> Void
    let onContinue: () -> Void

    private let vm = PatientInfoMenuViewModel()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                decorativeRings(in: geo.size)
                radialButtons(in: geo.size)
                titleAndChevrons
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 25)
                .onEnded { value in
                    if vm.shouldContinueOnSwipe(value) { onContinue() }
                }
        )
    }

    // MARK: - Title + bottom chevrons
    private var titleAndChevrons: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                Text("SET UP")
                    .font(.system(size: 18, weight: .medium))
                    .tracking(4)
                    .foregroundColor(.white.opacity(0.5))

                Text("Patient Profile")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .kerning(-0.5)
            }
            .padding(.top, 80)

            Spacer()

            Text("›  ›  ›")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(Color.white.opacity(0.45))
                .contentShape(Rectangle())
                .onTapGesture { onContinue() }
                .padding(.bottom, 40)
        }
    }

    // MARK: - Decorative rings (behind buttons)
    private func decorativeRings(in size: CGSize) -> some View {
        ZStack {
            ForEach(vm.ringDiameters, id: \.self) { d in
                Circle()
                    .stroke(Color.white.opacity(0.25), lineWidth: 1.8)
                    .frame(width: d, height: d)
            }
        }
        .position(vm.ringCenter(in: size))
        .allowsHitTesting(false)
    }

    // MARK: - Buttons arranged around the ring center
    private func radialButtons(in size: CGSize) -> some View {
        let sections = InfoSection.allCases
        return ZStack {
            ForEach(Array(sections.enumerated()), id: \.element) { index, section in
                NavigationLink(value: section) {
                    PatientInfoSectionPill(section: section)
                }
                .buttonStyle(.plain)
                .position(vm.buttonPosition(index: index, count: sections.count, in: size))
            }
        }
    }
}

#Preview {
    PatientInfoMenuView(onBack: {}, onContinue: {})
}
