//
//  IconStyle.swift
//  GlassIconKit
//

import Foundation

/// Persistent keys and defaults for the icon-styling preferences.
///
/// Both values live in `UserDefaults.standard` and are read via `@AppStorage`,
/// so the host app and this package observe the same toggles.
public enum IconStyle {
    /// Glossy Liquid Glass finish for icon tiles and glyphs.
    public static let candyModeKey = "candyMode"
    /// Circular icon tiles instead of rounded squares.
    public static let roundIconsKey = "iconShapeRound"

    /// Candy Mode is on until the user turns it off.
    public static let candyModeDefault = true
    /// Icon tiles are rounded squares until the user opts into circles.
    public static let roundIconsDefault = false
}

/// Persistent keys and defaults for app-wide decorative effects.
///
/// These live beside the icon preferences because `GlassIconKit` participates
/// in both effects: Candy glyphs use a sheen gradient and a small drop shadow.
public enum VisualEffectStyle {
    /// Decorative drop shadows throughout the app.
    public static let shadowsEnabledKey = "shadowsEnabled"
    /// Decorative gradient fills and sheens throughout the app.
    public static let gradientsEnabledKey = "gradientsEnabled"

    /// Shadows are on until the user turns them off.
    public static let shadowsEnabledDefault = true
    /// Gradients are on until the user turns them off.
    public static let gradientsEnabledDefault = true
}
