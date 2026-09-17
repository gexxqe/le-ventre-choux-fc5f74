// 10x primitive: airbnb/design-tokens v1
import SwiftUI

/// Central design tokens for Le Ventre à Choux styled with the Olive Brass palette:
/// Primary #24483B (Deep Olive French Bistro Green),
/// Accent #B69245 (Warm Brass / Gold),
/// Background #F6F1E8 (Warm Cream / Ivory),
/// Surface #FFF9F1 (Soft Warm Ivory Paper),
/// Text #2C2924 (Charcoal / Deep Espresso Ink).
@available(iOS 17.0, *)
public enum StayTokens {
    // MARK: Grounds & surfaces (Olive Brass Palette)
    /// Primary background (~#F6F1E8 warm cream/ivory)
    public static let ground = Color(red: 0.965, green: 0.945, blue: 0.910)
    /// Warm cream ground used on payoff and summary cards (~#F1ECE0)
    public static let groundWarm = Color(red: 0.945, green: 0.925, blue: 0.880)
    /// Surface for cards, dialogs, sheets (~#FFF9F1)
    public static let surface = Color(red: 1.000, green: 0.976, blue: 0.945)
    /// Soft neutral fill for pill buttons and subtle cards (~#EDE6D8)
    public static let surfaceSoft = Color(red: 0.929, green: 0.902, blue: 0.847)
    /// Translucent surface for overlaid controls
    public static let glass = Color(red: 1.000, green: 0.976, blue: 0.945).opacity(0.92)
    /// Dark translucent scrim
    public static let scrim = Color.black.opacity(0.55)
    /// Hairline borders and dividers (~#DDD5C4)
    public static let hairline = Color(red: 0.867, green: 0.835, blue: 0.769)
    /// Stronger border for selected items (deep olive green)
    public static let borderSelected = Color(red: 0.141, green: 0.282, blue: 0.231)

    // MARK: Ink & Brand Colors
    /// Primary charcoal text (~#2C2924)
    public static let ink = Color(red: 0.173, green: 0.161, blue: 0.141)
    /// Secondary muted text (~#686259)
    public static let inkSecondary = Color(red: 0.408, green: 0.384, blue: 0.349)
    /// Text on deep green or dark accent surfaces
    public static let inkOnAccent = Color.white

    // MARK: Brand & Accent (Deep Olive #24483B & Warm Brass #B69245)
    /// Primary Deep Olive Green (~#24483B)
    public static let brandPrimary = Color(red: 0.141, green: 0.282, blue: 0.231)
    /// Warm Brass Accent (~#B69245)
    public static let accent = Color(red: 0.714, green: 0.573, blue: 0.271)
    /// Committing-CTA gradient endpoints
    public static let accentGradientStart = Color(red: 0.141, green: 0.282, blue: 0.231) // Deep Olive
    public static let accentGradientEnd = Color(red: 0.200, green: 0.360, blue: 0.300)   // Rich Forest Olive
    
    /// Horizontal capsule gradient used by primary actions
    public static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accentGradientStart, accentGradientEnd],
            startPoint: .leading, endPoint: .trailing
        )
    }
    
    /// Brass gradient for highlight buttons and stars
    public static var brassGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.714, green: 0.573, blue: 0.271), Color(red: 0.820, green: 0.670, blue: 0.350)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
    
    /// Dark CTA button color (~#24483B)
    public static let ctaDark = Color(red: 0.141, green: 0.282, blue: 0.231)
    /// Laurel/award warm brass (~#B69245)
    public static let laurel = Color(red: 0.714, green: 0.573, blue: 0.271)
    /// Confirmation green for success states
    public static let positive = Color(red: 0.141, green: 0.450, blue: 0.250)

    // MARK: Radii
    public static let radiusCard: CGFloat = 18
    public static let radiusMedia: CGFloat = 16
    public static let radiusField: CGFloat = 12
    public static let radiusSheet: CGFloat = 24

    // MARK: Shadow
    public static let shadow = Color.black.opacity(0.08)

    // MARK: Typography with French Bistro Serif display & Sans body
    public static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .serif)
    }
    public static func bistroTitle(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .serif)
    }
    
    public static let titleFont: Font = .system(size: 20, weight: .semibold, design: .serif)
    public static let headlineFont: Font = .system(.headline, weight: .semibold)
    public static let bodyFont: Font = .system(.body)
    public static let captionFont: Font = .system(.footnote)
    public static let metaFont: Font = .system(.caption)

    // MARK: Bistro Atmosphere Scene Palettes
    public static let scenePalettes: [StayScenePalette] = [
        StayScenePalette( // Warm Bistro Ivory & Brass
            top: Color(red: 0.941, green: 0.894, blue: 0.827),
            bottom: Color(red: 0.851, green: 0.769, blue: 0.678),
            glow: Color(red: 0.714, green: 0.573, blue: 0.271).opacity(0.6)),
        StayScenePalette( // Olive & Sage
            top: Color(red: 0.855, green: 0.890, blue: 0.839),
            bottom: Color(red: 0.141, green: 0.282, blue: 0.231).opacity(0.4),
            glow: Color(red: 0.933, green: 0.957, blue: 0.906)),
        StayScenePalette( // French Terracotta & Brass
            top: Color(red: 0.925, green: 0.847, blue: 0.808),
            bottom: Color(red: 0.816, green: 0.667, blue: 0.612),
            glow: Color(red: 0.976, green: 0.918, blue: 0.878)),
        StayScenePalette( // Deep Olive Lounge
            top: Color(red: 0.180, green: 0.320, blue: 0.260),
            bottom: Color(red: 0.120, green: 0.220, blue: 0.180),
            glow: Color(red: 0.714, green: 0.573, blue: 0.271).opacity(0.5)),
    ]

    public static func scenePalette(_ index: Int) -> StayScenePalette {
        scenePalettes[abs(index) % scenePalettes.count]
    }
}

/// One neutral gradient scene palette.
@available(iOS 17.0, *)
public struct StayScenePalette {
    public var top: Color
    public var bottom: Color
    public var glow: Color

    public init(top: Color, bottom: Color, glow: Color) {
        self.top = top
        self.bottom = bottom
        self.glow = glow
    }
}

/// The set's abstract stand-in for photography: a warm French bistro gradient with soft glow.
@available(iOS 17.0, *)
public struct StayScene: View {
    public var paletteIndex: Int

    public init(paletteIndex: Int = 0) {
        self.paletteIndex = paletteIndex
    }

    public var body: some View {
        let palette = StayTokens.scenePalette(paletteIndex)
        GeometryReader { proxy in
            let side = max(proxy.size.width, proxy.size.height)
            LinearGradient(colors: [palette.top, palette.bottom],
                           startPoint: .top, endPoint: .bottom)
                .overlay {
                    ZStack {
                        Circle()
                            .fill(palette.glow.opacity(0.65))
                            .frame(width: side * 0.62)
                            .blur(radius: side * 0.14)
                            .offset(x: -side * 0.18, y: -side * 0.16)
                        Circle()
                            .fill(palette.glow.opacity(0.4))
                            .frame(width: side * 0.42)
                            .blur(radius: side * 0.12)
                            .offset(x: side * 0.24, y: side * 0.20)
                    }
                }
                .clipped()
        }
        .accessibilityHidden(true)
    }
}
