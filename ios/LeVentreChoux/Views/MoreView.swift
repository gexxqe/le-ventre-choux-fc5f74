import SwiftUI

public struct MoreView: View {
    @ObservedObject var store: RestaurantStore
    @Binding var selectedTab: Int
    @State private var showingAdminLogin = false
    
    public init(store: RestaurantStore, selectedTab: Binding<Int>) {
        self.store = store
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Restaurant Mini Profile
                    miniProfileCard
                    
                    // MARK: - Main Sections
                    VStack(spacing: 12) {
                        NavigationLink {
                            ContactLocationSubpage(store: store, selectedTab: $selectedTab)
                        } label: {
                            MoreNavRow(icon: "mappin.and.ellipse", title: "Contact & Localisation", subtitle: "Adresse, téléphone, itinéraire et carte")
                        }
                        
                        NavigationLink {
                            HoursGallerySubpage(store: store)
                        } label: {
                            MoreNavRow(icon: "clock.fill", title: "Horaires & Galerie photos", subtitle: "Horaires d'ouverture et ambiance du restaurant")
                        }
                    }
                    
                    // MARK: - Social Media Section (Facebook)
                    facebookSection
                    
                    // MARK: - Admin Access Section
                    adminAccessSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 36)
            }
            .background(StayTokens.ground.ignoresSafeArea())
            .navigationTitle("Plus d'informations")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showingAdminLogin) {
                AdminView(store: store)
            }
        }
    }
    
    // MARK: - Mini Profile Card
    private var miniProfileCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(StayTokens.accent)
            
            Text(store.profile.name)
                .font(StayTokens.bistroTitle(22))
                .foregroundStyle(StayTokens.brandPrimary)
            
            Text("5 Place de la République, 85600 Montaigu-Vendée")
                .font(.system(size: 13))
                .foregroundStyle(StayTokens.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(StayTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
    }
    
    // MARK: - Facebook Section
    private var facebookSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("RÉSEAUX SOCIAUX")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(StayTokens.inkSecondary)
            
            Button {
                if let url = URL(string: store.profile.facebookURL) {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(red: 0.10, green: 0.40, blue: 0.85))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.2.wave.2.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Page Facebook du restaurant")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(StayTokens.ink)
                        Text("Suivez notre actualité et nos plats du jour")
                            .font(.system(size: 12))
                            .foregroundStyle(StayTokens.inkSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(StayTokens.inkSecondary)
                }
                .padding(14)
                .background(StayTokens.surface)
                .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Admin Access Section
    private var adminAccessSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ESPACE RESTAURATEUR")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(StayTokens.inkSecondary)
            
            Button {
                showingAdminLogin = true
            } label: {
                HStack(spacing: 12) {
                    Circle()
                        .fill(StayTokens.brandPrimary.opacity(0.12))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 18))
                                .foregroundStyle(StayTokens.brandPrimary)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Administration du restaurant")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(StayTokens.ink)
                        Text("Modifier la carte, les horaires, les réservations et infos")
                            .font(.system(size: 12))
                            .foregroundStyle(StayTokens.inkSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(StayTokens.inkSecondary)
                }
                .padding(14)
                .background(StayTokens.groundWarm)
                .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.accent.opacity(0.4), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Row Subcomponent
struct MoreNavRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(StayTokens.brandPrimary.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 17))
                        .foregroundStyle(StayTokens.brandPrimary)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(StayTokens.ink)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(StayTokens.inkSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(StayTokens.inkSecondary)
        }
        .padding(14)
        .background(StayTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
    }
}
