import SwiftUI

public struct HomeView: View {
    @ObservedObject var store: RestaurantStore
    @Binding var selectedTab: Int
    @State private var showingReservationSheet = false
    
    public init(store: RestaurantStore, selectedTab: Binding<Int>) {
        self.store = store
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Hero Banner
                    heroSection
                    
                    // MARK: - Quick Action Buttons (Appeler, Itinéraire, Menu, Avis)
                    quickActionsGrid
                    
                    // MARK: - Today's Special & Status Pill
                    statusAndDailySpecialSection
                    
                    // MARK: - Notre cuisine Section
                    notreCuisineSection
                    
                    // MARK: - Highlights / Key Features
                    highlightsSection
                    
                    // MARK: - Bottom Reservation Teaser
                    reservationTeaserSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 36)
            }
            .background(StayTokens.ground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "fork.knife.circle.fill")
                            .foregroundStyle(StayTokens.accent)
                        Text(store.profile.name)
                            .font(.system(size: 17, weight: .bold, design: .serif))
                            .foregroundStyle(StayTokens.brandPrimary)
                    }
                }
            }
        }
    }
    
    // MARK: - Hero
    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomLeading) {
                // Bistro visual background
                RoundedRectangle(cornerRadius: StayTokens.radiusMedia, style: .continuous)
                    .fill(Color.clear)
                    .frame(height: 200)
                    .overlay(StayScene(paletteIndex: 3))
                    .overlay(
                        LinearGradient(
                            colors: [Color.black.opacity(0.1), Color.black.opacity(0.75)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusMedia, style: .continuous))
                
                VStack(alignment: .leading, spacing: 8) {
                    // Rating Pill
                    HStack(spacing: 6) {
                        HStack(spacing: 2) {
                            ForEach(0..<5) { idx in
                                Image(systemName: idx < Int(store.profile.googleRating.rounded()) ? "star.fill" : "star.leadinghalf.filled")
                                    .font(.caption2)
                                    .foregroundStyle(StayTokens.accent)
                            }
                        }
                        Text(String(format: "%.1f / 5", store.profile.googleRating))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                        Text("•  \(store.profile.reviewCount) avis")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.45))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(StayTokens.accent.opacity(0.6), lineWidth: 1))
                    
                    Text(store.profile.name)
                        .font(StayTokens.display(28))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
                    
                    Text(store.profile.tagline)
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .foregroundStyle(Color(red: 0.95, green: 0.92, blue: 0.85))
                }
                .padding(18)
            }
            
            // Two Prominent CTAs: Réserver une table & Voir le menu
            HStack(spacing: 12) {
                Button {
                    selectedTab = 2 // Tab Réserver
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Réserver une table")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(StayTokens.inkOnAccent)
                    .background(StayTokens.accentGradient)
                    .clipShape(Capsule())
                    .shadow(color: StayTokens.brandPrimary.opacity(0.35), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                
                Button {
                    selectedTab = 1 // Tab Menu
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "book.pages")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Voir le menu")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(StayTokens.brandPrimary)
                    .background(StayTokens.surface)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(StayTokens.hairline, lineWidth: 1.5))
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Quick Action Buttons
    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ACCÈS RAPIDE")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(StayTokens.inkSecondary)
                .padding(.leading, 4)
            
            HStack(spacing: 10) {
                // Appeler
                Button {
                    let cleanPhone = store.profile.phoneNumber.filter { "0123456789+".contains($0) }
                    if let url = URL(string: "tel://\(cleanPhone)") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    QuickActionCell(icon: "phone.fill", label: "Appeler", color: StayTokens.brandPrimary)
                }
                .buttonStyle(.plain)
                
                // Itinéraire
                Button {
                    let encoded = "5 Place de la République, 85600 Montaigu-Vendée, France".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    if let url = URL(string: "maps://?q=\(encoded)") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    QuickActionCell(icon: "location.fill", label: "Itinéraire", color: StayTokens.accent)
                }
                .buttonStyle(.plain)
                
                // Menu
                Button {
                    selectedTab = 1
                } label: {
                    QuickActionCell(icon: "fork.knife", label: "Menu", color: StayTokens.brandPrimary)
                }
                .buttonStyle(.plain)
                
                // Avis
                Button {
                    selectedTab = 3
                } label: {
                    QuickActionCell(icon: "star.fill", label: "Avis", color: StayTokens.accent)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Status & Daily Special
    private var statusAndDailySpecialSection: some View {
        VStack(spacing: 12) {
            let status = store.currentStatusText
            HStack(spacing: 12) {
                Circle()
                    .fill(status.isOpen ? StayTokens.positive : Color.red.opacity(0.85))
                    .frame(width: 10, height: 10)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(status.status)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(StayTokens.ink)
                    Text(status.detail)
                        .font(.system(size: 12))
                        .foregroundStyle(StayTokens.inkSecondary)
                }
                Spacer()
                
                NavigationLink {
                    HoursGallerySubpage(store: store)
                } label: {
                    Text("Horaires")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(StayTokens.brandPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(StayTokens.surfaceSoft)
                        .clipShape(Capsule())
                }
            }
            .padding(14)
            .background(StayTokens.surface)
            .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
            
            // Daily special card
            if let dailySpecial = store.menuItems.first(where: { $0.isDailySpecial }) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("PLAT DU JOUR DU CHEF", systemImage: "sparkles")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.0)
                            .foregroundStyle(StayTokens.accent)
                        
                        Spacer()
                        
                        Text(String(format: "%.2f €", dailySpecial.price))
                            .font(.system(size: 16, weight: .bold, design: .serif))
                            .foregroundStyle(StayTokens.brandPrimary)
                    }
                    
                    Text(dailySpecial.name)
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .foregroundStyle(StayTokens.ink)
                    
                    Text(dailySpecial.itemDescription)
                        .font(.system(size: 13))
                        .foregroundStyle(StayTokens.inkSecondary)
                        .lineLimit(3)
                    
                    HStack {
                        Text(store.profile.dailySpecialNotice)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(StayTokens.inkSecondary)
                            .italic()
                        
                        Spacer()
                        
                        Button {
                            selectedTab = 1
                        } label: {
                            Text("Voir la carte →")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(StayTokens.brandPrimary)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(16)
                .background(StayTokens.groundWarm)
                .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous)
                        .stroke(StayTokens.accent.opacity(0.4), lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Notre cuisine
    private var notreCuisineSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "laurel.leading")
                    .font(.title3)
                    .foregroundStyle(StayTokens.accent)
                Text("Notre cuisine")
                    .font(StayTokens.bistroTitle(22))
                    .foregroundStyle(StayTokens.brandPrimary)
                Image(systemName: "laurel.trailing")
                    .font(.title3)
                    .foregroundStyle(StayTokens.accent)
            }
            
            Text(store.profile.introStory)
                .font(.system(size: 14, weight: .regular))
                .lineSpacing(4)
                .foregroundStyle(StayTokens.ink)
            
            // Highlight Badges
            HStack(spacing: 8) {
                FeatureBadge(icon: "carrot.fill", label: "Omelette végétarienne")
                FeatureBadge(icon: "sparkles", label: "Fait maison")
                FeatureBadge(icon: "eurosign.circle.fill", label: "Prix accessibles")
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(StayTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
    }
    
    // MARK: - Highlights Grid
    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("L'EXPÉRIENCE DU RESTAURANT")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(StayTokens.inkSecondary)
                .padding(.leading, 4)
            
            VStack(spacing: 10) {
                HighlightRow(
                    icon: "heart.fill",
                    title: "Accueil & Convivialité",
                    subtitle: "Une équipe souriante et un service rapide au cœur de la Place de la République."
                )
                HighlightRow(
                    icon: "leaf.fill",
                    title: "Plats Végétariens Soignés",
                    subtitle: "Des alternatives savoureuses et préparées minute pour tous les régimes."
                )
                HighlightRow(
                    icon: "map.fill",
                    title: "Emplacement Idéal",
                    subtitle: "5 Place de la République, 85600 Montaigu-Vendée — Accès et stationnement faciles."
                )
            }
        }
    }
    
    // MARK: - Reservation Teaser
    private var reservationTeaserSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Envie d'une bonne table ?")
                        .font(StayTokens.bistroTitle(18))
                        .foregroundStyle(StayTokens.brandPrimary)
                    Text("Réservez en ligne en quelques secondes.")
                        .font(.system(size: 13))
                        .foregroundStyle(StayTokens.inkSecondary)
                }
                Spacer()
                
                Button {
                    selectedTab = 2
                } label: {
                    Text("Réserver")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(StayTokens.inkOnAccent)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(StayTokens.brandPrimary)
                        .clipShape(Capsule())
                }
            }
            .padding(16)
            .background(StayTokens.groundWarm)
            .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
        }
    }
}

// MARK: - Subcomponents
struct QuickActionCell: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(color.opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(color)
                )
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(StayTokens.ink)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(StayTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
    }
}

struct FeatureBadge: View {
    let icon: String
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(StayTokens.accent)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(StayTokens.ink)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(StayTokens.surfaceSoft)
        .clipShape(Capsule())
    }
}

struct HighlightRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(StayTokens.brandPrimary.opacity(0.1))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundStyle(StayTokens.brandPrimary)
                )
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundStyle(StayTokens.ink)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(StayTokens.inkSecondary)
            }
            Spacer()
        }
        .padding(14)
        .background(StayTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
    }
}
