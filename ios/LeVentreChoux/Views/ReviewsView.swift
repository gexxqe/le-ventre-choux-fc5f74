import SwiftUI

public struct ReviewsView: View {
    @ObservedObject var store: RestaurantStore
    
    public init(store: RestaurantStore) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Rating Header Card
                    ratingHeaderCard
                    
                    // MARK: - Themes Highlights
                    reviewThemesSection
                    
                    // MARK: - Customer Reviews List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TÉMOIGNAGES CLIENTS")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.2)
                            .foregroundStyle(StayTokens.inkSecondary)
                            .padding(.leading, 4)
                        
                        ForEach(store.reviews) { rev in
                            ReviewItemCard(review: rev)
                        }
                    }
                    
                    // MARK: - External Google Maps Action
                    googleMapsReviewButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 36)
            }
            .background(StayTokens.ground.ignoresSafeArea())
            .navigationTitle("Avis & Témoignages")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Rating Header Card
    private var ratingHeaderCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "laurel.leading")
                    .font(.title)
                    .foregroundStyle(StayTokens.accent)
                
                Text(String(format: "%.1f", store.profile.googleRating))
                    .font(StayTokens.display(48))
                    .foregroundStyle(StayTokens.ink)
                
                Image(systemName: "laurel.trailing")
                    .font(.title)
                    .foregroundStyle(StayTokens.accent)
            }
            
            HStack(spacing: 4) {
                ForEach(0..<5) { idx in
                    Image(systemName: "star.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(StayTokens.accent)
                }
            }
            
            Text("Note globale calculée sur \(store.profile.reviewCount) avis clients Google")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(StayTokens.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background(StayTokens.groundWarm)
        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous)
                .stroke(StayTokens.hairline, lineWidth: 1)
        )
    }
    
    // MARK: - Themes Highlights
    private var reviewThemesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("POINTS FORTS RÉCURRENTS")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(StayTokens.inkSecondary)
            
            VStack(spacing: 8) {
                ThemePillRow(icon: "person.crop.circle.badge.checkmark", title: "Accueil très chaleureux et poli", count: "Équipe souriante")
                ThemePillRow(icon: "sparkles", title: "Cuisine fait maison & Ingrédients frais", count: "Qualité constante")
                ThemePillRow(icon: "carrot.fill", title: "Options végétariennes réussies", count: "Omelette réputée")
                ThemePillRow(icon: "eurosign.circle.fill", title: "Prix très raisonnables", count: "Excellent rapport Q/P")
                ThemePillRow(icon: "bolt.fill", title: "Service rapide et efficace", count: "Idéal pour le midi")
            }
        }
        .padding(16)
        .background(StayTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
    }
    
    // MARK: - Google Maps Button
    private var googleMapsReviewButton: some View {
        Button {
            let encoded = "Le Ventre à Choux 5 Place de la République 85600 Montaigu-Vendée".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(encoded)") {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 16))
                Text("Voir tous les 78 avis sur Google")
                    .font(.system(size: 15, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(StayTokens.brandPrimary)
            .background(StayTokens.surface)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(StayTokens.brandPrimary, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Review Subcomponents
struct ThemePillRow: View {
    let icon: String
    let title: String
    let count: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(StayTokens.brandPrimary)
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(StayTokens.ink)
            
            Spacer()
            
            Text(count)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(StayTokens.accent)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(StayTokens.accent.opacity(0.12))
                .clipShape(Capsule())
        }
    }
}

struct ReviewItemCard: View {
    let review: CustomerReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle()
                    .fill(StayTokens.brandPrimary.opacity(0.12))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(String(review.authorName.prefix(1)))
                            .font(.system(size: 15, weight: .bold, design: .serif))
                            .foregroundStyle(StayTokens.brandPrimary)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.authorName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(StayTokens.ink)
                    Text(review.dateText)
                        .font(.system(size: 11))
                        .foregroundStyle(StayTokens.inkSecondary)
                }
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(0..<review.rating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(StayTokens.accent)
                    }
                }
            }
            
            Text(review.comment)
                .font(.system(size: 13))
                .lineSpacing(3)
                .foregroundStyle(StayTokens.ink)
            
            HStack {
                Text(review.tag)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(StayTokens.brandPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(StayTokens.surfaceSoft)
                    .clipShape(Capsule())
            }
        }
        .padding(14)
        .background(StayTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
    }
}
