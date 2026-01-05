//
//  SuggestionScrollWithIndicator.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 16.12.2025.
//


import SwiftUI

struct SuggestionScrollWithIndicator: View {
    let items: [ICDSuggestion]
    let height: CGFloat
    let onSelect: (ICDSuggestion) -> Void

    @State private var contentHeight: CGFloat = 1
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .topTrailing) {

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    GeometryReader { geo in
                        Color.clear
                            .preference(
                                key: ScrollOffsetKey.self,
                                value: -geo.frame(in: .named("suggestions")).minY
                            )
                    }
                    .frame(height: 0)

                    ForEach(items) { suggestion in
                        Button {
                            onSelect(suggestion)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(suggestion.code)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.primary)

                                Text(suggestion.name)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Divider()
                    }
                }
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear { contentHeight = max(geo.size.height, 1) }
                            .onChange(of: geo.size.height) { _, newValue in
                                contentHeight = max(newValue, 1)
                            }
                    }
                )
            }
            .coordinateSpace(name: "suggestions")
            .onPreferenceChange(ScrollOffsetKey.self) { offset in
                scrollOffset = offset
            }
            .frame(height: height)

            if contentHeight > height {
                let trackH = height
                let thumbH = max(24, trackH * (height / contentHeight))
                let maxOffset = max(contentHeight - height, 1)
                let progress = min(max(scrollOffset / maxOffset, 0), 1)
                let thumbY = (trackH - thumbH) * progress

                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.primary.opacity(0.10))
                        .frame(width: 4, height: trackH)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.primary.opacity(0.35))
                        .frame(width: 4, height: thumbH)
                        .offset(y: thumbY)
                }
                .padding(.trailing, 2)
                .allowsHitTesting(false)
            }
        }
    }
}

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
