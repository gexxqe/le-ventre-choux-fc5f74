// 10x primitive: airbnb/review-row v1
import SwiftUI

/// A single review for any reviewed item — a stay, a restaurant, a product —
/// with a five-star row beside dot-separated meta (date, context), a clamped
/// body with an underlined show-more button, and an identity row pairing a
/// scene-tinted monogram disc with name over location, in the
/// marketplace/booking voice.
@available(iOS 17.0, *)
public struct StayReviewRowModel: Identifiable {
    public var id: String
    /// 0–5 filled stars.
    public var stars: Int
    /// e.g. "March 2025".
    public var dateLabel: String
    /// Optional extra meta after the date, e.g. "Stayed a few nights".
    public var context: String?
    public var body: String
    /// Reviewer display name; the monogram uses its first letter.
    public var name: String
    /// e.g. "Naperville, Illinois". Hidden when nil.
    public var location: String?
    /// Scene palette index tinting the monogram disc.
    public var sceneIndex: Int

    public init(id: String, stars: Int, dateLabel: String, context: String? = nil,
                body: String, name: String, location: String? = nil, sceneIndex: Int = 0) {
        self.id = id
        self.stars = stars
        self.dateLabel = dateLabel
        self.context = context
        self.body = body
        self.name = name
        self.location = location
        self.sceneIndex = sceneIndex
    }
}

@available(iOS 17.0, *)
public struct StayReviewRowConfig {
    /// Body line limit when clamped; nil shows the full body.
    public var bodyLineLimit: Int? = 4
    public var showMoreTitle: String = "Show more"
    /// Puts the identity row above the stars (the observed all-reviews order)
    /// instead of below the body (the observed listing-detail order).
    public var identityFirst = false
    public var avatarDiameter: CGFloat = 40

    public init() {}
}

@available(iOS 17.0, *)
public struct StayReviewRow: View {
    public var model: StayReviewRowModel
    public var config: StayReviewRowConfig
    public var onShowMore: (() -> Void)?

    public init(model: StayReviewRowModel,
                config: StayReviewRowConfig = .init(),
                onShowMore: (() -> Void)? = nil) {
        self.model = model
        self.config = config
        self.onShowMore = onShowMore
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if config.identityFirst { identityRow }
            VStack(alignment: .leading, spacing: 8) {
                metaRow
                bodyBlock
            }
            if !config.identityFirst { identityRow }
        }
    }

    private var metaRow: some View {
        HStack(spacing: 6) {
            HStack(spacing: 1) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: index < model.stars ? "star.fill" : "star")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(index < model.stars
                                         ? StayTokens.ink
                                         : StayTokens.hairline)
                }
            }
            Text("·").font(StayTokens.metaFont).foregroundStyle(StayTokens.inkSecondary)
            Text(model.dateLabel)
                .font(StayTokens.metaFont)
                .foregroundStyle(StayTokens.inkSecondary)
            if let context = model.context {
                Text("·").font(StayTokens.metaFont).foregroundStyle(StayTokens.inkSecondary)
                Text(context)
                    .font(StayTokens.metaFont)
                    .foregroundStyle(StayTokens.inkSecondary)
                    .lineLimit(1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(metaAccessibilityLabel)
    }

    private var metaAccessibilityLabel: String {
        var label = "\(model.stars) of 5 stars, \(model.dateLabel)"
        if let context = model.context { label += ", \(context)" }
        return label
    }

    private var bodyBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(model.body)
                .font(StayTokens.bodyFont)
                .foregroundStyle(StayTokens.ink)
                .lineLimit(config.bodyLineLimit)
                .fixedSize(horizontal: false, vertical: true)
            if let onShowMore, config.bodyLineLimit != nil {
                Button {
                    onShowMore()
                } label: {
                    Text(config.showMoreTitle)
                        .font(.system(.footnote, weight: .semibold))
                        .underline()
                        .foregroundStyle(StayTokens.ink)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityHint("Shows the full review")
            }
        }
    }

    private var identityRow: some View {
        HStack(spacing: 10) {
            monogram
            VStack(alignment: .leading, spacing: 1) {
                Text(model.name)
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundStyle(StayTokens.ink)
                if let location = model.location {
                    Text(location)
                        .font(StayTokens.metaFont)
                        .foregroundStyle(StayTokens.inkSecondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var monogram: some View {
        let palette = StayTokens.scenePalette(model.sceneIndex)
        return Circle()
            .fill(LinearGradient(colors: [palette.top, palette.bottom],
                                 startPoint: .top, endPoint: .bottom))
            .frame(width: config.avatarDiameter, height: config.avatarDiameter)
            .overlay {
                Text(model.name.prefix(1).uppercased())
                    .font(.system(size: config.avatarDiameter * 0.42, weight: .semibold))
                    .foregroundStyle(StayTokens.ink.opacity(0.72))
            }
            .accessibilityHidden(true)
    }
}

#Preview("Review rows") {
    if #available(iOS 17.0, *) {
        VStack(alignment: .leading, spacing: 24) {
            StayReviewRow(
                model: .init(id: "1", stars: 5, dateLabel: "March 2025",
                             context: "Stayed a few nights",
                             body: "I stayed here for 2 nights and it was perfect. The host is very responsive and friendly, and the location made it easy to walk to most places. I felt very safe and would absolutely book again if I'm back in the city.",
                             name: "Laura", location: "Naperville, Illinois", sceneIndex: 1),
                onShowMore: {})
            Rectangle().fill(StayTokens.hairline).frame(height: 1)
            StayReviewRow(
                model: .init(id: "2", stars: 4, dateLabel: "2 weeks ago",
                             body: "Lovely stay with plenty of natural light. Check-in was easy.",
                             name: "Axel", location: "Lyon, France", sceneIndex: 3),
                config: {
                    var config = StayReviewRowConfig()
                    config.identityFirst = true
                    return config
                }())
        }
        .padding(20)
        .background(StayTokens.ground)
    }
}
