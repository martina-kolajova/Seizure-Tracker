
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
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                isAnimating.toggle()
            }
        }
    }
}

// #Preview {
// //     MeshGradientView()
// // }

// MARK: - First screen (white, brain icon, title)
struct WelcomeView: View {
    let onStart: () -> Void

    var body: some View {
        ZStack {
            // Animated mesh gradient background
            MeshGradientView()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    ZStack {
                        Image(systemName: "brain")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.white)
                    }

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



// Reusable “glass” card with blur & rounded corners
struct GlassCard<Content: View>: View {
    let content: () -> Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.12))
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 22)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )

            content()
                .padding(18)
        }
    }
}

#Preview {
    ContentView()
}
