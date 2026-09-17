// 10x primitive: airbnb/sticky-cta-bar v1
import SwiftUI

/// A pinned bottom conversion bar for any bookable detail screen — a stay,
/// a class, a table, a ticket — with an optional soft urgency strip above a
/// hairline-topped white bar: leading underlined price with caption and an
/// optional check chip, trailing the coral-gradient committing CTA capsule,
/// in the marketplace/booking voice. Pin with `safeAreaInset(edge: .bottom)`.
@available(iOS 17.0, *)
public struct StayStickyCTABarConfig {
    /// Optional strip above the bar, e.g. "Rare find! This place is usually booked".
    public var urgencyText: String?
    public var urgencyGlyph: String = "sparkle"
    /// Optional check line under the price, e.g. "Free cancellation".
    public var checkText: String?
    /// Dark instead of coral CTA (the observed intermediate-step variant).
    public var usesDarkCTA = false
    public var priceFont: Font = .system(.title3, weight: .semibold)

    public init() {}
}

@available(iOS 17.0, *)
public struct StayStickyCTABar: View {
    /// e.g. "$356".
    public var price: String
    /// e.g. "For 2 nights · Sep 5–7".
    public var caption: String?
    /// CTA label, e.g. "Reserve".
    public var ctaTitle: String
    public var config: StayStickyCTABarConfig
    public var onPriceTap: (() -> Void)?
    public var onCTA: () -> Void

    public init(price: String,
                caption: String? = nil,
                ctaTitle: String,
                config: StayStickyCTABarConfig = .init(),
                onPriceTap: (() -> Void)? = nil,
                onCTA: @escaping () -> Void) {
        self.price = price
        self.caption = caption
        self.ctaTitle = ctaTitle
        self.config = config
        self.onPriceTap = onPriceTap
        self.onCTA = onCTA
    }

    public var body: some View {
        VStack(spacing: 0) {
            if let urgency = config.urgencyText {
                HStack(spacing: 6) {
                    Image(systemName: config.urgencyGlyph)
                        .font(.system(size: 11, weight: .semibold))
                    Text(urgency)
                        .font(.system(.caption, weight: .medium))
                }
                .foregroundStyle(StayTokens.ink)
                .frame(maxWidth: .infinity, minHeight: 32)
                .background(StayTokens.surfaceSoft)
            }
            HStack(alignment: .center, spacing: 12) {
                priceBlock
                Spacer(minLength: 12)
                ctaButton
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(StayTokens.surface)
            .overlay(alignment: .top) {
                if config.urgencyText == nil {
                    Rectangle().fill(StayTokens.hairline).frame(height: 1)
                }
            }
        }
    }

    private var priceBlock: some View {
        Button {
            onPriceTap?()
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(price)
                    .font(config.priceFont)
                    .monospacedDigit()
                    .underline(onPriceTap != nil)
                    .foregroundStyle(StayTokens.ink)
                if let caption {
                    Text(caption)
                        .font(StayTokens.metaFont)
                        .foregroundStyle(StayTokens.inkSecondary)
                }
                if let check = config.checkText {
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                        Text(check)
                            .font(StayTokens.metaFont)
                    }
                    .foregroundStyle(StayTokens.ink)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(onPriceTap == nil)
        .accessibilityElement(children: .combine)
        .accessibilityHint(onPriceTap == nil ? "" : "Shows price details")
    }

    private var ctaButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onCTA()
        } label: {
            Text(ctaTitle)
                .font(.system(.body, weight: .semibold))
                .foregroundStyle(StayTokens.inkOnAccent)
                .padding(.horizontal, 28)
                .frame(minHeight: 50)
                .background {
                    if config.usesDarkCTA {
                        Capsule().fill(StayTokens.ctaDark)
                    } else {
                        Capsule().fill(StayTokens.accentGradient)
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview("Sticky CTA bar") {
    if #available(iOS 17.0, *) {
        VStack {
            Spacer()
            StayStickyCTABar(
                price: "$356",
                caption: "For 2 nights · Sep 5–7",
                ctaTitle: "Reserve",
                config: {
                    var config = StayStickyCTABarConfig()
                    config.urgencyText = "Rare find! This place is usually booked"
                    config.checkText = "Free cancellation"
                    return config
                }(),
                onPriceTap: {},
                onCTA: {})
        }
        .background(StayTokens.ground)
    }
}
