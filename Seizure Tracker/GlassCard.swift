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
