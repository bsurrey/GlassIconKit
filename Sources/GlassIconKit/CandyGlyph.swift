//
//  CandyGlyph.swift
//  GlassIconKit
//

import SwiftUI

/// Renders an icon glyph with the "Candy Mode" glass finish — a top-to-bottom
/// sheen gradient over the glyph's base color, a bright specular highlight along
/// the top edge, and a soft drop shadow so the symbol reads like a raised piece
/// of glass. When disabled the glyph is a plain, flat fill in its base color.
///
/// `base` is the glyph's resting color (white on glass tiles, or a contrasting
/// foreground on colored tiles), so the effect looks right on both light and
/// dark glyphs.
public struct CandyGlyph: ViewModifier {
    @AppStorage(VisualEffectStyle.shadowsEnabledKey) private var shadowsEnabled = VisualEffectStyle.shadowsEnabledDefault
    @AppStorage(VisualEffectStyle.gradientsEnabledKey) private var gradientsEnabled = VisualEffectStyle.gradientsEnabledDefault

    /// Whether the glass finish is applied; when `false` the glyph is a flat
    /// `base` fill.
    public var enabled: Bool
    /// The glyph's resting color, from which the sheen and highlight are built.
    public var base: Color

    /// Creates the modifier. Prefer the `candyGlyph(_:base:)` convenience
    /// on `View`.
    public init(enabled: Bool, base: Color = .white) {
        self.enabled = enabled
        self.base = base
    }

    public func body(content: Content) -> some View {
        if enabled {
            // The sheen is tuned for light glyphs. On a dark glyph an additive
            // white highlight washes the top to gray and a faded fill goes
            // translucent over the bright tile — so soften both for dark glyphs:
            // keep the fill opaque and use a small, faint highlight (a glossy
            // reflection) instead of a large wash.
            let dark = base.isDark
            content
                .foregroundStyle(
                    gradientsEnabled
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [base, base.opacity(dark ? 1.0 : 0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        : AnyShapeStyle(base)
                )
                .overlay {
                    LinearGradient(colors: [.white.opacity(dark ? 0.35 : 1.0), .clear],
                                   startPoint: .top,
                                   endPoint: dark ? UnitPoint(x: 0.5, y: 0.42) : .center)
                        .opacity(gradientsEnabled ? 1 : 0)
                        .blendMode(.plusLighter)
                        .mask { content }
                }
                .shadow(
                    color: shadowsEnabled ? .black.opacity(dark ? 0.15 : 0.25) : .clear,
                    radius: 0.5,
                    y: 0.5
                )
        } else {
            content.foregroundStyle(base)
        }
    }
}

public extension View {
    /// Applies the Candy Mode glass finish to a glyph view, tinted around `base`.
    func candyGlyph(_ enabled: Bool, base: Color = .white) -> some View {
        modifier(CandyGlyph(enabled: enabled, base: base))
    }
}

// MARK: - Previews

#Preview("CandyGlyph · on vs off") {
    let symbols = ["star.fill", "bell.fill", "drop.fill", "bolt.fill"]
    return VStack(spacing: 28) {
        ForEach([true, false], id: \.self) { enabled in
            VStack(spacing: 10) {
                Text(enabled ? "Candy on" : "Candy off")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
                HStack(spacing: 28) {
                    ForEach(symbols, id: \.self) { name in
                        Image(systemName: name)
                            .font(.system(size: 30, weight: .semibold))
                            .candyGlyph(enabled)
                    }
                }
            }
        }
    }
    .padding(40)
    .background(LinearGradient(colors: [.blue, .indigo], startPoint: .top, endPoint: .bottom))
}
