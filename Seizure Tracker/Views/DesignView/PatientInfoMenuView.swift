//
//  PatientInfoMenuView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 16.12.2025.
//


import SwiftUI

struct PatientInfoMenuView: View {
    let onBack: () -> Void
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            topBar

            HStack {
                GeometryReader { geo in
                    ZStack {
                        let circleCenter = CGPoint(
                            x: -geo.size.width * 0.10,
                            y: geo.size.height * 0.5
                        )

                        Image("logo-white")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white.opacity(0.7))
                            .scaledToFit()
                            .frame(width: geo.size.height * 2)
                            .position(circleCenter)
                            .allowsHitTesting(false)

                        let totalSections = InfoSection.allCases.count
                        let radius = geo.size.height * 0.36

                        let startAngle = -60.0 * .pi / 180.0
                        let endAngle   =  60.0 * .pi / 180.0
                        let angleStep  = totalSections > 1
                        ? (endAngle - startAngle) / Double(totalSections - 1)
                        : 0

                        let buttonOffsetX = geo.size.width * 0.22

                        ForEach(Array(InfoSection.allCases.enumerated()), id: \.1) { index, section in
                            let angle = startAngle + Double(index) * angleStep

                            let baseX = circleCenter.x + cos(angle) * radius
                            let baseY = circleCenter.y + sin(angle) * radius

                            let x = baseX + buttonOffsetX
                            let y = baseY

                            NavigationLink(value: section) {
                                PatientInfoSectionPill(section: section)
                            }
                            .buttonStyle(.plain)
                            .position(x: x, y: y)
                        }
                    }
                }
                .frame(width: 260)

                Spacer()
            }
            .padding(.top, 10)
            .padding(.leading, 8)

            Spacer()

            bottomButton
        }
    }

    private var topBar: some View {
        HStack {
            Button(action: onBack) {
                Label("Back", systemImage: "chevron.left")
                    .foregroundColor(.white)
            }
            Spacer()
            Text("Set up patient profile")
                .foregroundColor(.white)
                .font(.headline)
            Spacer()
            Color.clear.frame(width: 60, height: 3)
        }
        .padding(.horizontal, 24)
        .padding(.top, 40)
    }

    private var bottomButton: some View {
        HStack {
            Spacer()
            Button(action: onContinue) {
                HStack(spacing: 8) {
                    Text("Continue to tracker").font(.headline)
                    Image(systemName: "arrow.right.circle.fill")
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .foregroundColor(.white)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .shadow(color: .black.opacity(0.4), radius: 12, y: 6)
            Spacer()
        }
        .padding(.bottom, 40)
    }
}

struct PatientInfoSectionPill: View {
    let section: InfoSection

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: section.iconName)
            Text(section.rawValue)
                .font(.subheadline)
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 10, y: 6)
    }
}
