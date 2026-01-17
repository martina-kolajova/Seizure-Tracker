//
//  ProfileBottomBar.swift
//
//  Created by Martina Kolajová on 16.12.2025.
//


import SwiftUI


//struct ProfileBottomBar: View {
//
//    /// Tells the parent to open the Profile sheet
//    @Binding var isProfilePresented: Bool
//
//    var body: some View {
//        HStack(spacing: 10) {
//            barButton(
//                "Profile",
//                systemImage: "person.crop.circle.fill"
//            ) {
//                isProfilePresented = true
//            }
//        }
//        .padding(10)
//        .background(.ultraThinMaterial, in: Capsule())
//        .overlay(Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1))
//        .shadow(color: .black.opacity(0.35), radius: 16, y: 8)
//    }
//
//    private func barButton(
//        _ title: String,
//        systemImage: String,
//        action: @escaping () -> Void
//    ) -> some View {
//        Button(action: action) {
//            HStack(spacing: 8) {
//                Image(systemName: systemImage)
//                Text(title)
//                    .font(.subheadline.weight(.semibold))
//            }
//            .foregroundStyle(.white)
//            .padding(.vertical, 10)
//            .padding(.horizontal, 14)
//            .background(Color.white.opacity(0.12), in: Capsule())
//            .overlay(
//                Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1)
//            )
//        }
//        .buttonStyle(.plain)
//    }
//}
