//
//  topBar.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 03.01.2026.
//

import SwiftUI

extension TrackerLayout {

    var topTabBar: some View {
        HStack(spacing: 8) {
            segTab(.tracker)
            segTab(.daily)
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
    }

    func segTab(_ tab: TopTab) -> some View {
        let isOn = (vm.selectedTab == tab)

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.92)) {
                vm.selectedTab = tab
            }
        } label: {
            Text(tab.rawValue)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white.opacity(isOn ? 0.98 : 0.70))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isOn ? Color.white.opacity(0.18) : Color.white.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(isOn ? 0.22 : 0.10), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
