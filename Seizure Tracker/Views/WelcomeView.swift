//
//  WelcomeView.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 02.12.2025.
//
import SwiftUI

struct WelcomeView: View {
    let onStart: () -> Void

    var body: some View {
        ZStack {
            MeshGradientView()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "brain")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.white)

                    Text("EpiLog")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)

                    Text("A simple, personal way to log seizures.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                Button(action: onStart) {
                    Text("Get started")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(.purple)
                        .cornerRadius(16)
                        .shadow(radius: 8, y: 4)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .shadow(color: .black.opacity(0.5), radius: 12, y: 6)
            }
        }
    }
}
