// 10x primitive: airbnb/review-summary v1
import SwiftUI

/// A rating payoff header for any reviewed item — a stay, a restaurant, a
/// product, a service provider — with a huge laurel-flanked rating numeral,
/// an award title and caption, and a hairline-divided facts strip pairing a
/// five-row rating histogram with glyph-anchored category score columns, in
/// the marketplace/booking voice.
@available(iOS 17.0, *)
public struct StayReviewCategoryScore: Identifiable {
    public var id: String
    /// e.g. "Cleanliness".
    public var title: String
    /// e.g. 4.8.
    public var score: Double
    /// SF Symbol anchored at the column base, e.g. "sparkles".
    public var glyph: String

    public init(id: String, title: String, score: Double, glyph: String) {
        self.id = id
        self.title = title
        self.score = score
        self.glyph = glyph
    }
}

@available(iOS 17.0, *)
public struct StayReviewSummaryConfig {
    /// Award line under the numeral, e.g. "Guest favorite". Hidden when nil.
    public var awardTitle: String?
    /// Caption under the award line. Hidden when nil.
    public var caption: String?
    /// Title over the histogram column, e.g. "Overall rating".
    public var histogramTitle: String = "Overall rating"
    public var ratingFont: Font = StayTokens.display(54)
    /// Shows the gold laurels beside the numeral.
    public var showsLaurels = true

    public init() {}
}

@available(iOS 17.0, *)
public struct StayReviewSummary: View {
    /// e.g. 4.96.
    public var rating: Double
    /// Histogram fractions for 5★ down to 1★, each 0...1 of the tallest bucket.
    public var distribution: [Double]
    public var categories: [StayReviewCategoryScore]
    public var config: StayReviewSummaryConfig

    public init(rating: Double,
                distribution: [Double] = [],
                categories: [StayReviewCategoryScore] = [],
                config: StayReviewSummaryConfig = .init()) {
        self.rating = rating
        self.distribution = distribution
        self.categories = categories
        self.config = config
    }

    public var body: some View {
        VStack(spacing: 0) {
            hero
            if !distribution.isEmpty || !categories.isEmpty {
                factsStrip.padding(.top, 22)
            }
        }
    }

    // MARK: Hero

    private var hero: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                if config.showsLaurels {
                    Image(systemName: "laurel.leading")
                        .font(.system(size: 34, weight: .medium))
                        .foregroundStyle(StayTokens.laurel)
                }
                Text(rating.formatted(.number.precision(.fractionLength(1...2))))
                    .font(config.ratingFont)
                    .foregroundStyle(StayTokens.ink)
                if config.showsLaurels {
                    Image(systemName: "laurel.trailing")
                        .font(.system(size: 34, weight: .medium))
                        .foregroundStyle(StayTokens.laurel)
                }
            }
            if let award = config.awardTitle {
                Text(award)
                    .font(StayTokens.headlineFont)
                    .foregroundStyle(StayTokens.ink)
            }
            if let caption = config.caption {
                Text(caption)
                    .font(StayTokens.captionFont)
                    .foregroundStyle(StayTokens.inkSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(heroAccessibilityLabel)
    }

    private var heroAccessibilityLabel: String {
        var label = "Rated \(rating.formatted(.number.precision(.fractionLength(1...2)))) out of 5"
        if let award = config.awardTitle { label += ", \(award)" }
        if let caption = config.caption { label += ". \(caption)" }
        return label
    }

    // MARK: Facts strip

    private var factsStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 0) {
                if !distribution.isEmpty {
                    histogramColumn
                    divider
                }
                ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                    categoryColumn(category)
                    if index < categories.count - 1 { divider }
                }
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(StayTokens.hairline)
            .frame(width: 1, height: 84)
            .padding(.horizontal, 16)
    }

    private var histogramColumn: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(config.histogramTitle)
                .font(StayTokens.metaFont)
                .foregroundStyle(StayTokens.ink)
            VStack(alignment: .leading, spacing: 3) {
                ForEach(Array(distribution.prefix(5).enumerated()), id: \.offset) { index, fraction in
                    HStack(spacing: 6) {
                        Text("\(5 - index)")
                            .font(.system(size: 9, weight: .medium))
                            .monospacedDigit()
                            .foregroundStyle(StayTokens.inkSecondary)
                        Capsule()
                            .fill(StayTokens.hairline)
                            .frame(width: 96, height: 3)
                            .overlay(alignment: .leading) {
                                Capsule()
                                    .fill(StayTokens.ink)
                                    .frame(width: 96 * min(max(fraction, 0), 1), height: 3)
                            }
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(histogramAccessibilityLabel)
    }

    private var histogramAccessibilityLabel: String {
        let parts = distribution.prefix(5).enumerated().map { index, fraction in
            "\(5 - index) star \(Int((min(max(fraction, 0), 1) * 100).rounded())) percent"
        }
        return "\(config.histogramTitle): " + parts.joined(separator: ", ")
    }

    private func categoryColumn(_ category: StayReviewCategoryScore) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(category.title)
                .font(StayTokens.metaFont)
                .foregroundStyle(StayTokens.ink)
            Text(category.score.formatted(.number.precision(.fractionLength(1))))
                .font(.system(.title3, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(StayTokens.ink)
            Spacer(minLength: 0)
            Image(systemName: category.glyph)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(StayTokens.ink)
        }
        .frame(height: 84, alignment: .top)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(category.title) \(category.score.formatted(.number.precision(.fractionLength(1)))) out of 5")
    }
}

#Preview("Review summary") {
    if #available(iOS 17.0, *) {
        StayReviewSummary(
            rating: 4.96,
            distribution: [1.0, 0.28, 0.08, 0.03, 0.02],
            categories: [
                .init(id: "cleanliness", title: "Cleanliness", score: 4.8, glyph: "sparkles"),
                .init(id: "accuracy", title: "Accuracy", score: 5.0, glyph: "checkmark.circle"),
                .init(id: "checkin", title: "Check-in", score: 5.0, glyph: "key"),
                .init(id: "value", title: "Value", score: 4.9, glyph: "tag"),
            ],
            config: {
                var config = StayReviewSummaryConfig()
                config.awardTitle = "Guest favorite"
                config.caption = "This home is in the top 5% of eligible listings based on ratings, reviews, and reliability"
                return config
            }())
        .padding(20)
        .background(StayTokens.groundWarm)
    }
}
