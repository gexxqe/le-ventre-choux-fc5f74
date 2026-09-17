// 10x primitive: airbnb/guest-stepper-sheet v1
import SwiftUI

/// A who's-coming stepper panel for any party-size or quantity picker —
/// guests by age band, rooms, tickets, seats — with hairline-separated rows
/// of title over caption and bordered circular minus/plus controls around a
/// live count, an optional footnote link row, and an optional bottom bar,
/// in the marketplace/booking voice.
@available(iOS 17.0, *)
public struct StayGuestStepperRow: Identifiable {
    public var id: String
    /// e.g. "Adults".
    public var title: String
    /// e.g. "Ages 13 or above". Hidden when nil.
    public var subtitle: String?
    public var minValue: Int
    public var maxValue: Int

    public init(id: String, title: String, subtitle: String? = nil,
                minValue: Int = 0, maxValue: Int = 16) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.minValue = minValue
        self.maxValue = maxValue
    }
}

@available(iOS 17.0, *)
public struct StayGuestStepperSheetConfig {
    /// Big panel title, e.g. "Who?". Hidden when nil.
    public var title: String? = "Who?"
    /// Optional underlined footnote button under the last row.
    public var footnote: String?
    public var controlDiameter: CGFloat = 34
    public var rowMinHeight: CGFloat = 64

    public init() {}
}

@available(iOS 17.0, *)
public struct StayGuestStepperSheet: View {
    public var rows: [StayGuestStepperRow]
    /// Host-owned counts keyed by row id; missing keys read as the row minimum.
    public var counts: [String: Int]
    public var config: StayGuestStepperSheetConfig
    public var onChange: (String, Int) -> Void
    public var onFootnote: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(rows: [StayGuestStepperRow],
                counts: [String: Int],
                config: StayGuestStepperSheetConfig = .init(),
                onChange: @escaping (String, Int) -> Void,
                onFootnote: (() -> Void)? = nil) {
        self.rows = rows
        self.counts = counts
        self.config = config
        self.onChange = onChange
        self.onFootnote = onFootnote
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = config.title {
                Text(title)
                    .font(StayTokens.display(24))
                    .foregroundStyle(StayTokens.ink)
                    .padding(.bottom, 8)
                    .accessibilityAddTraits(.isHeader)
            }
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                stepperRow(row)
                if index < rows.count - 1 {
                    Rectangle().fill(StayTokens.hairline).frame(height: 1)
                }
            }
            if let footnote = config.footnote {
                Button {
                    onFootnote?()
                } label: {
                    Text(footnote)
                        .font(StayTokens.metaFont)
                        .underline()
                        .foregroundStyle(StayTokens.inkSecondary)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
                .padding(.bottom, 8)
            }
        }
    }

    private func stepperRow(_ row: StayGuestStepperRow) -> some View {
        let count = counts[row.id] ?? row.minValue
        return HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(row.title)
                    .font(.system(.body, weight: .semibold))
                    .foregroundStyle(StayTokens.ink)
                if let subtitle = row.subtitle {
                    Text(subtitle)
                        .font(StayTokens.captionFont)
                        .foregroundStyle(StayTokens.inkSecondary)
                }
            }
            Spacer(minLength: 12)
            circleControl(glyph: "minus", enabled: count > row.minValue) {
                step(row, count: count, delta: -1)
            }
            .accessibilityLabel("Decrease \(row.title)")
            Text("\(count)")
                .font(.system(.body, weight: .medium))
                .monospacedDigit()
                .foregroundStyle(StayTokens.ink)
                .frame(minWidth: 26)
                .contentTransition(.numericText())
                .accessibilityHidden(true)
            circleControl(glyph: "plus", enabled: count < row.maxValue) {
                step(row, count: count, delta: 1)
            }
            .accessibilityLabel("Increase \(row.title)")
        }
        .frame(minHeight: config.rowMinHeight)
        .accessibilityElement(children: .contain)
        .accessibilityValue("\(row.title): \(count)")
    }

    private func circleControl(glyph: String, enabled: Bool,
                               action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: glyph)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(enabled ? StayTokens.inkSecondary : StayTokens.hairline)
                .frame(width: config.controlDiameter, height: config.controlDiameter)
                .background {
                    Circle().strokeBorder(
                        enabled ? StayTokens.inkSecondary.opacity(0.6) : StayTokens.hairline,
                        lineWidth: 1
                    )
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    private func step(_ row: StayGuestStepperRow, count: Int, delta: Int) {
        let next = min(max(count + delta, row.minValue), row.maxValue)
        guard next != count else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if reduceMotion {
            onChange(row.id, next)
        } else {
            withAnimation(.snappy(duration: 0.2)) { onChange(row.id, next) }
        }
    }
}

#Preview("Guest steppers") {
    if #available(iOS 17.0, *) {
        struct Demo: View {
            @State private var counts = ["adults": 1, "children": 0, "infants": 0, "pets": 0]
            var body: some View {
                StayGuestStepperSheet(
                    rows: [
                        .init(id: "adults", title: "Adults", subtitle: "Ages 13 or above"),
                        .init(id: "children", title: "Children", subtitle: "Ages 2 – 12"),
                        .init(id: "infants", title: "Infants", subtitle: "Under 2", maxValue: 5),
                        .init(id: "pets", title: "Pets", maxValue: 3),
                    ],
                    counts: counts,
                    config: {
                        var config = StayGuestStepperSheetConfig()
                        config.footnote = "Bringing a service animal?"
                        return config
                    }(),
                    onChange: { counts[$0] = $1 })
                .padding(20)
                .background(StayTokens.surface, in: RoundedRectangle(cornerRadius: StayTokens.radiusCard))
                .padding(14)
                .background(StayTokens.surfaceSoft)
            }
        }
        return AnyView(Demo())
    }
    return AnyView(EmptyView())
}
