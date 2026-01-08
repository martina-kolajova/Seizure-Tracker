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
                    Image( "EpiLog-white")
                        .resizable()
                        .renderingMode(.original)   // keep the original colors of your logo
                        .scaledToFit()
                        .frame(width: 160, height: 160)

                    //Text("EpiLog")
                      //  .font(.system(size: 34, weight: .bold))
                        //.foregroundColor(.white)

                    Text("A simple, personal way to log seizures.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                HStack {
                    Spacer()
                    Button(action: onStart) {
                        HStack(spacing: 8) {
                            Text("Create profile")
                                .font(.headline)
                            Image("logo-white")
                                     .resizable()
                                     .renderingMode(.original)     // keep white color
                                     .scaledToFit()
                                     .frame(width: 35, height: 35) // perfect icon size
                                     .padding(.leading, 4)
                             }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .foregroundColor(.white)
                        .background(
                            .ultraThinMaterial,
                            in: Capsule()
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .shadow(color: .black.opacity(0.4), radius: 12, y: 6)
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}


#Preview {
    ContentView()
}
