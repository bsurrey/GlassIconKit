//
//  Contrast.swift
//  GlassIconKit
//
//  A small, self-contained luminance helper so the kit's glyph finish can
//  adapt to dark base colors without depending on the host app.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

extension Color {
    /// Whether this color reads as dark (low perceptual luminance). Used to soften
    /// the glossy glyph finish, which is tuned for light/white glyphs.
    var isDark: Bool {
        luminance < 0.5
    }

    /// Approximate perceptual luminance, 0 (black) … 1 (white) — Rec. 601 luma
    /// weights on the gamma-encoded sRGB components. Cheap, and plenty of
    /// precision for a dark/light split.
    ///
    /// Colors that can't be resolved to RGB — and any future platform without
    /// UIKit (both supported platforms have it) — are treated as light, which
    /// keeps the default finish tuned for white glyphs.
    private var luminance: CGFloat {
        #if canImport(UIKit)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else { return 1 }
        // Extended sRGB reports out-of-gamut components outside 0…1; clamp so
        // wide-gamut colors can't push the result out of range.
        func clamped(_ component: CGFloat) -> CGFloat { min(max(component, 0), 1) }
        return 0.299 * clamped(r) + 0.587 * clamped(g) + 0.114 * clamped(b)
        #else
        return 1
        #endif
    }
}
