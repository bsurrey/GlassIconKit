//
//  GlassIcon.swift
//  GlassIconKit
//

import SwiftUI

/// A ready-to-use icon: a tinted tile with an SF Symbol, styled by the shared
/// "Candy Mode" / "Round Icons" preferences. This is the convenience wrapper
/// around ``GlassIconTile`` for the common case of "a symbol on a colored tile".
///
/// ```swift
/// GlassIcon("flame.fill", tint: .orange)            // 29pt, white glyph
/// GlassIcon("drop.fill", tint: .blue, size: 44)     // larger
/// ```
///
/// The glyph is sized with the SwiftUI `.font` modifier at a point size that's a
/// fixed fraction (`glyphScale`) of the tile, then centered. SF Symbols are
/// "treated like fonts" by the system and are optically balanced relative to the
/// font's cap height, so font-based sizing keeps every glyph at a consistent
/// visual size *and* optically centered — unlike `.resizable()`, which scales a
/// symbol's tight bounding box and makes top-heavy glyphs (e.g. `heart.fill`)
/// look high and fuller glyphs look oversized. See HIG ▸ SF Symbols / Icons.
///
/// `cornerRadius` defaults to a proportion of `size`. `glyphBase` defaults to
/// white on every tint — pass a color to override. Set `gradient` to give the
/// (flat, non-Candy) tile a shaded `tint.gradient` fill.
///
/// The icon is decorative: like ``GlassIconTile``, it is hidden from assistive
/// technologies. Put the meaning on the enclosing row or control.
public struct GlassIcon: View {
    /// Glyph point size as a fraction of the tile size (the rest is margin).
    public static let defaultGlyphScale: CGFloat = 0.5

    private let systemName: String
    private let tint: Color
    private let size: CGFloat
    private let glyphScale: CGFloat
    private let cornerRadius: CGFloat?
    private let glyphBase: Color?
    private let gradient: Bool

    /// Creates a tinted tile bearing an SF Symbol.
    ///
    /// - Parameters:
    ///   - systemName: The SF Symbol to draw. An empty string renders a bare
    ///     tile with no glyph.
    ///   - tint: The tile's fill color (flat) or glass tint (Candy Mode).
    ///   - size: Side length of the square tile, in points. 29 matches the
    ///     standard settings-row icon. Negative values are treated as zero.
    ///   - glyphScale: Glyph point size as a fraction of `size`.
    ///   - cornerRadius: Corner radius of the rounded-square tile. `nil` (the
    ///     default) derives it from `size`. Ignored when Round Icons is on.
    ///   - glyphBase: The glyph's resting color; `nil` means white.
    ///   - gradient: Fills the flat (non-Candy) tile with `tint.gradient`
    ///     instead of a solid color.
    public init(
        _ systemName: String,
        tint: Color,
        size: CGFloat = 29,
        glyphScale: CGFloat = GlassIcon.defaultGlyphScale,
        cornerRadius: CGFloat? = nil,
        glyphBase: Color? = nil,
        gradient: Bool = false
    ) {
        self.systemName = systemName
        self.tint = tint
        self.size = max(size, 0)
        self.glyphScale = max(glyphScale, 0)
        self.cornerRadius = cornerRadius
        self.glyphBase = glyphBase
        self.gradient = gradient
    }

    public var body: some View {
        GlassIconTile(
            tint: tint,
            size: size,
            cornerRadius: cornerRadius,   // nil → the tile derives it from size
            glyphBase: glyphBase ?? .white,
            gradient: gradient
        ) {
            // Empty name renders a bare tile (matches a "no icon" tracker).
            // Sized as a font so the symbol uses Apple's optical sizing and
            // alignment (consistent across symbols, properly centered).
            if !systemName.isEmpty {
                Image(systemName: systemName)
                    .font(.system(size: size * glyphScale, weight: .semibold))
            }
        }
    }
}

// MARK: - Previews

/// An in-memory defaults store so previews can show specific style states.
private func iconStyleStore(candy: Bool, round: Bool) -> UserDefaults {
    let store = UserDefaults(suiteName: "GlassIconKit.preview.\(candy).\(round)")!
    store.set(candy, forKey: IconStyle.candyModeKey)
    store.set(round, forKey: IconStyle.roundIconsKey)
    return store
}

private let previewSwatches: [(symbol: String, tint: Color)] = [
    ("flame.fill", .orange),
    ("drop.fill", .blue),
    ("heart.fill", .pink),
    ("leaf.fill", .green),
    ("bolt.fill", .yellow),
    ("star.fill", .purple)
]

/// Inspection overlay: the tile bounds, the glyph fit-box, and a center
/// crosshair, so you can judge how a glyph sits within its tile.
private struct AlignmentGrid: View {
    let size: CGFloat
    var round: Bool = false
    var glyphScale: CGFloat = GlassIcon.defaultGlyphScale

    var body: some View {
        let mid = size / 2
        let box = size * glyphScale
        ZStack {
            Group {                                       // tile bounds (match shape)
                if round {
                    Circle().stroke(Color.red.opacity(0.45), lineWidth: 0.5)
                } else {
                    Rectangle().stroke(Color.red.opacity(0.45), lineWidth: 0.5)
                }
            }
            Rectangle()                                   // glyph fit-box
                .stroke(Color.red.opacity(0.22), lineWidth: 0.5)
                .frame(width: box, height: box)
            Path { p in                                   // center crosshair
                p.move(to: CGPoint(x: mid, y: 0)); p.addLine(to: CGPoint(x: mid, y: size))
                p.move(to: CGPoint(x: 0, y: mid)); p.addLine(to: CGPoint(x: size, y: mid))
            }
            .stroke(Color.red.opacity(0.6), style: StrokeStyle(lineWidth: 0.5, dash: [3, 2]))
        }
        .frame(width: size, height: size)
        .allowsHitTesting(false)
    }
}

/// One combined preview hosting every GlassIcon demo, switched with a picker.
private struct GlassIconGallery: View {
    private enum Demo: String, CaseIterable, Identifiable {
        case alignment = "Align"
        case sizes = "Sizes"
        case symbols = "Symbols"
        case colors = "Colors"
        case gradient = "Gradient"
        case styles = "Styles"
        var id: String { rawValue }
    }

    @State private var demo: Demo = .alignment

    var body: some View {
        VStack(spacing: 16) {
            Picker("Demo", selection: $demo) {
                ForEach(Demo.allCases) { Text($0.rawValue).tag($0) }
            }
            #if !os(watchOS)
            .pickerStyle(.segmented)
            #endif
            .padding([.horizontal, .top])

            ScrollView {
                demoView
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
        }
    }

    // A separate View per demo keeps each body small and fast to type-check.
    private var demoView: AnyView {
        switch demo {
        case .alignment: AnyView(AlignmentDemo())
        case .sizes: AnyView(SizesDemo())
        case .symbols: AnyView(SymbolsDemo())
        case .colors: AnyView(ColorsDemo())
        case .gradient: AnyView(GradientDemo())
        case .styles: AnyView(StylesDemo())
        }
    }
}

// MARK: Gallery demos

private struct AlignmentDemo: View {
    private let symbols = ["heart.fill", "flame.fill", "trophy.fill", "leaf.fill", "star.fill", "drop.fill"]
    private let sizes: [CGFloat] = [56, 96]

    var body: some View {
        HStack(alignment: .top, spacing: 36) {
            column(round: false)
            column(round: true)
        }
    }

    private func column(round: Bool) -> some View {
        VStack(spacing: 14) {
            Text(round ? "Round" : "Square").font(.headline)
            ForEach(symbols, id: \.self) { name in
                row(name: name, round: round)
            }
        }
        .defaultAppStorage(iconStyleStore(candy: true, round: round))
    }

    private func row(name: String, round: Bool) -> some View {
        HStack(spacing: 20) {
            ForEach(sizes, id: \.self) { side in
                ZStack {
                    GlassIcon(name, tint: .blue, size: side)
                    AlignmentGrid(size: side, round: round)
                }
            }
        }
    }
}

private struct SizesDemo: View {
    private let sizes: [CGFloat] = [24, 32, 44, 56, 72, 96, 128]
    var body: some View {
        VStack(spacing: 24) {
            ForEach(["heart.fill", "flame.fill"], id: \.self) { name in
                HStack(alignment: .center, spacing: 16) {
                    ForEach(sizes, id: \.self) { side in
                        GlassIcon(name, tint: .pink, size: side)
                    }
                }
            }
        }
    }
}

private struct SymbolsDemo: View {
    private let symbols = ["heart.fill", "flame.fill", "drop.fill", "bell.fill",
                           "star.fill", "leaf.fill", "trophy.fill", "bolt.fill",
                           "person.fill", "calendar", "checkmark", "cloud.fill"]
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 64), spacing: 16)], spacing: 16) {
            ForEach(symbols, id: \.self) { name in
                GlassIcon(name, tint: .blue, size: 56)
            }
        }
        .padding(.horizontal, 24)
    }
}

private struct ColorsDemo: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 16)], spacing: 16) {
            ForEach(previewSwatches, id: \.symbol) { item in
                GlassIcon(item.symbol, tint: item.tint, size: 52)
            }
        }
        .padding(.horizontal, 24)
    }
}

private struct GradientDemo: View {
    var body: some View {
        // Gradient only shows on the flat tile, so force Candy Mode off here.
        VStack(spacing: 22) {
            ForEach([false, true], id: \.self) { useGradient in
                VStack(spacing: 10) {
                    Text(useGradient ? "Gradient" : "Solid")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    HStack(spacing: 14) {
                        ForEach(previewSwatches, id: \.symbol) { item in
                            GlassIcon(item.symbol, tint: item.tint, size: 52, gradient: useGradient)
                        }
                    }
                }
            }
        }
        .defaultAppStorage(iconStyleStore(candy: false, round: false))
    }
}

private struct StylesDemo: View {
    private struct Combo: Identifiable {
        let label: String
        let candy: Bool
        let round: Bool
        var id: String { label }
    }
    private let combos = [
        Combo(label: "Candy · Square", candy: true, round: false),
        Combo(label: "Candy · Round", candy: true, round: true),
        Combo(label: "Flat · Square", candy: false, round: false),
        Combo(label: "Flat · Round", candy: false, round: true)
    ]
    var body: some View {
        VStack(spacing: 22) {
            ForEach(combos) { combo in
                VStack(spacing: 10) {
                    Text(combo.label).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    HStack(spacing: 14) {
                        ForEach(previewSwatches.prefix(5), id: \.symbol) { item in
                            GlassIcon(item.symbol, tint: item.tint, size: 48)
                        }
                    }
                    .defaultAppStorage(iconStyleStore(candy: combo.candy, round: combo.round))
                }
            }
        }
    }
}

#Preview("GlassIcon Gallery") {
    GlassIconGallery()
}
