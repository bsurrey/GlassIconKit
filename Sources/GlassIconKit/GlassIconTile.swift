//
//  GlassIconTile.swift
//  GlassIconKit
//

import SwiftUI

/// A rounded, tinted icon tile with a glyph on top. The tile and glyph respond
/// to the shared icon-styling preferences:
///
/// - **Candy Mode** renders the tile as tinted Liquid Glass and gives the glyph
///   the glossy `candyGlyph` finish; when off, the tile is a flat tinted fill
///   and the glyph is a flat `glyphBase` fill.
/// - **Round Icons** switches the tile between a circle and a rounded square.
///
/// Set `gradient` to fill the tile with `tint.gradient` (a subtle shaded fill)
/// instead of a solid color. It applies to the flat (non-Candy) tile; in Candy
/// Mode the Liquid Glass material governs the surface, so the flag has no effect.
///
/// Provide the glyph (typically an `Image(systemName:)` with a font) via the
/// trailing closure; the tile applies the finish for you.
///
/// In dark mode, Candy tiles add two depth cues that dark backgrounds would
/// otherwise swallow: a tint-colored ambient glow (honoring the shared
/// shadows preference) and a faint top-lit rim along the tile edge, so the
/// glass keeps its elevation and richness without ambient light to refract.
///
/// The tile is decorative: it is hidden from assistive technologies, since it
/// always sits beside text that carries the meaning (a settings row, a tracker
/// title). If a tile must be announced on its own, label its container:
///
/// ```swift
/// GlassIconTile(tint: .teal) { Text("7") }
///     .accessibilityElement()
///     .accessibilityLabel("Seven-day streak")
/// ```
public struct GlassIconTile<Glyph: View>: View {
    private let tint: Color
    private let size: CGFloat
    private let cornerRadius: CGFloat
    private let glyphBase: Color
    private let gradient: Bool
    private let glyph: Glyph

    @Environment(\.colorScheme) private var colorScheme

    @AppStorage(IconStyle.candyModeKey) private var candyMode = IconStyle.candyModeDefault
    @AppStorage(IconStyle.roundIconsKey) private var roundIcons = IconStyle.roundIconsDefault
    @AppStorage(VisualEffectStyle.gradientsEnabledKey) private var gradientsEnabled = VisualEffectStyle.gradientsEnabledDefault
    @AppStorage(VisualEffectStyle.shadowsEnabledKey) private var shadowsEnabled = VisualEffectStyle.shadowsEnabledDefault

    /// Creates a tile with a custom glyph view.
    ///
    /// - Parameters:
    ///   - tint: The tile's fill color (flat) or glass tint (Candy Mode).
    ///   - size: Side length of the square tile, in points. Negative values
    ///     are treated as zero.
    ///   - cornerRadius: Corner radius of the rounded-square tile. `nil` (the
    ///     default) derives it from `size`. Ignored when Round Icons is on.
    ///   - glyphBase: The glyph's resting color.
    ///   - gradient: Fills the flat (non-Candy) tile with `tint.gradient`
    ///     instead of a solid color.
    ///   - glyph: The glyph content, centered on the tile.
    public init(
        tint: Color,
        size: CGFloat = 29,
        cornerRadius: CGFloat? = nil,
        glyphBase: Color = .white,
        gradient: Bool = false,
        @ViewBuilder glyph: () -> Glyph
    ) {
        let side = max(size, 0)
        self.tint = tint
        self.size = side
        self.cornerRadius = max(cornerRadius ?? side * 0.25, 0)
        self.glyphBase = glyphBase
        self.gradient = gradient
        self.glyph = glyph()
    }

    private var tileShape: AnyShape {
        roundIcons
            ? AnyShape(Circle())
            : AnyShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    @ViewBuilder private var tileBackground: some View {
        if candyMode {
            Color.clear
                .frame(width: size, height: size)
                .glassEffect(.regular.tint(tint), in: tileShape)
        } else {
            tileShape
                .fill(gradient && gradientsEnabled ? AnyShapeStyle(tint.gradient) : AnyShapeStyle(tint))
                .frame(width: size, height: size)
        }
    }

    // In dark mode glass has little ambient light to refract, so the tile loses
    // the elevation and edge definition it gets for free on bright backgrounds.
    // Restore both with dark-only cues: a tint-colored ambient glow behind the
    // tile (a black drop shadow would vanish on a dark background) and a faint
    // top-lit rim along the tile edge. Light mode renders exactly as before.
    private var isDarkCandy: Bool { candyMode && colorScheme == .dark }

    /// Colored under-glow standing in for the drop shadow dark backgrounds
    /// swallow. Drawn as a blurred copy of the tile shape (not `.shadow`, whose
    /// silhouette is unreliable over glass rendering).
    @ViewBuilder private var darkModeGlow: some View {
        if isDarkCandy && shadowsEnabled {
            tileShape
                .fill(tint)
                .frame(width: size, height: size)
                .blur(radius: size * 0.18)
                .opacity(0.35)
                .offset(y: size * 0.05)
        }
    }

    /// Top-lit edge highlight so the glass rim reads without ambient light.
    /// Falls back to a uniform hairline when gradients are disabled.
    @ViewBuilder private var darkModeRim: some View {
        if isDarkCandy {
            tileShape
                .stroke(
                    gradientsEnabled
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [.white.opacity(0.25), .white.opacity(0.04)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        : AnyShapeStyle(Color.white.opacity(0.10)),
                    lineWidth: 1
                )
                .frame(width: size, height: size)
                .blendMode(.plusLighter)
        }
    }

    public var body: some View {
        tileBackground
            .background { darkModeGlow }
            .overlay { glyph.candyGlyph(candyMode, base: glyphBase) }
            .overlay { darkModeRim }
            .accessibilityHidden(true)   // decorative — see the type docs
    }
}

// MARK: - Previews

#Preview("GlassIconTile · custom glyph") {
    HStack(spacing: 16) {
        GlassIconTile(tint: .pink, size: 56, cornerRadius: 14) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 26, weight: .semibold))
        }
        GlassIconTile(tint: .teal, size: 56, cornerRadius: 14) {
            Text("7")
                .font(.system(size: 26, weight: .bold, design: .rounded))
        }
        GlassIconTile(tint: .indigo, size: 56, cornerRadius: 28) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 24, weight: .semibold))
        }
    }
    .padding(40)
    #if os(watchOS)
    .background(Color.black)
    #else
    .background(Color(.systemGroupedBackground))
    #endif
}
