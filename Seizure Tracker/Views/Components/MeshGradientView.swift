//
//  MeshGradientView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 02.12.2025.
//

import SwiftUI

struct MeshGradientView: View {
    @State private var isAnimating = false
    
    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [isAnimating ? 0.1 : 0.8, 0.5], [1.0, isAnimating ? 0.5 : 1],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                .purple, .indigo, .purple,
                isAnimating ? .mint : .purple, .blue, .blue,
                .purple, .indigo, .purple
            ]
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                isAnimating.toggle()
            }
        }
    }
}

// #Preview {
// //     MeshGradientView()
// // }

