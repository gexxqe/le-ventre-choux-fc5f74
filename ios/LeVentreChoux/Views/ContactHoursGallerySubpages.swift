import SwiftUI

// MARK: - Contact & Location Subpage
public struct ContactLocationSubpage: View {
    @ObservedObject var store: RestaurantStore
    @Binding var selectedTab: Int
    @Environment(\.dismiss) private var dismiss
    
    public init(store: RestaurantStore, selectedTab: Binding<Int>) {
        self.store = store
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Details
                VStack(spacing: 6) {
                    Text(store.profile.name)
                        .font(StayTokens.bistroTitle(22))
                        .foregroundStyle(StayTokens.brandPrimary)
                    
                    Text("Restaurant traditionnel au cœur de Montaigu-Vendée")
                        .font(.system(size: 13))
                        .foregroundStyle(StayTokens.inkSecondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(StayTokens.groundWarm)
                .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
                
                // Map placeholder & Address
                VStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: StayTokens.radiusMedia, style: .continuous)
                            .fill(StayTokens.surfaceSoft)
                            .frame(height: 180)
                            .overlay(StayScene(paletteIndex: 1))
                        
                        VStack(spacing: 8) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(StayTokens.accent)
                                .shadow(radius: 4)
                            Text("5 Place de la République")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(StayTokens.ink)
                            Text("85600 Montaigu-Vendée")
                                .font(.system(size: 13))
                                .foregroundStyle(StayTokens.inkSecondary)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusMedia, style: .continuous))
                    
                    // Action buttons
                    VStack(spacing: 10) {
                        // Directions Button
                        Button {
                            let query = "5 Place de la République, 85600 Montaigu-Vendée".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                            if let url = URL(string: "maps://?q=\(query)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "location.fill")
                                Text("Obtenir l'itinéraire")
                                    .font(.system(size: 15, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .foregroundStyle(StayTokens.inkOnAccent)
                            .background(StayTokens.brandPrimary)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        
                        // Call Button
                        Button {
                            let clean = store.profile.phoneNumber.filter { "0123456789+".contains($0) }
                            if let url = URL(string: "tel://\(clean)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "phone.fill")
                                Text("Appeler \(store.profile.phoneNumber)")
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
                .padding(16)
                .background(StayTokens.surface)
                .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
                
                // Practical Info Cards
                VStack(alignment: .leading, spacing: 12) {
                    Text("INFORMATIONS PRATIQUES")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.0)
                        .foregroundStyle(StayTokens.inkSecondary)
                    
                    InfoRowItem(icon: "phone", title: "Téléphone", value: store.profile.phoneNumber)
                    InfoRowItem(icon: "envelope", title: "Email", value: store.profile.emailNotice)
                    InfoRowItem(icon: "car.fill", title: "Stationnement", value: "Places disponibles sur la Place de la République")
                    InfoRowItem(icon: "figure.roll", title: "Accessibilité", value: "Accès PMR et salle de plain-pied")
                }
                .padding(16)
                .background(StayTokens.surface)
                .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(StayTokens.ground.ignoresSafeArea())
        .navigationTitle("Contact & Accès")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Hours & Gallery Subpage
public struct HoursGallerySubpage: View {
    @ObservedObject var store: RestaurantStore
    
    public init(store: RestaurantStore) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Current Live Status Banner
                let status = store.currentStatusText
                HStack(spacing: 12) {
                    Circle()
                        .fill(status.isOpen ? StayTokens.positive : Color.red.opacity(0.85))
                        .frame(width: 12, height: 12)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(status.status)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(StayTokens.ink)
                        Text(status.detail)
                            .font(.system(size: 13))
                            .foregroundStyle(StayTokens.inkSecondary)
                    }
                    Spacer()
                }
                .padding(16)
                .background(StayTokens.groundWarm)
                .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous)
                        .stroke(status.isOpen ? StayTokens.positive.opacity(0.4) : StayTokens.hairline, lineWidth: 1)
                )
                
                // MARK: - Weekly Hours Table
                VStack(alignment: .leading, spacing: 12) {
                    Text("HORAIRES D'OUVERTURE")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.0)
                        .foregroundStyle(StayTokens.inkSecondary)
                    
                    VStack(spacing: 8) {
                        ForEach(store.openingHours, id: \.dayName) { day in
                            HStack {
                                Text(day.dayName)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(StayTokens.ink)
                                    .frame(width: 90, alignment: .leading)
                                
                                Spacer()
                                
                                if day.isClosed {
                                    Text("Fermé")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(Color.red.opacity(0.8))
                                } else {
                                    Text("\(day.lunchStart) - \(day.lunchEnd)  •  \(day.dinnerStart) - \(day.dinnerEnd)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(StayTokens.inkSecondary)
                                }
                            }
                            .padding(.vertical, 4)
                            Divider()
                        }
                    }
                }
                .padding(16)
                .background(StayTokens.surface)
                .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
                
                // MARK: - Atmosphere & Photo Gallery
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("GALERIE DU RESTAURANT")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.0)
                            .foregroundStyle(StayTokens.inkSecondary)
                        Spacer()
                        Text("Ambiance & Plats")
                            .font(.system(size: 11))
                            .foregroundStyle(StayTokens.accent)
                    }
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(Array(store.photos.enumerated()), id: \.element.id) { index, photo in
                            VStack(alignment: .leading, spacing: 6) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous)
                                        .fill(StayTokens.surfaceSoft)
                                        .frame(height: 100)
                                        .overlay(StayScene(paletteIndex: index))
                                    
                                    Image(systemName: photo.systemIcon)
                                        .font(.system(size: 30))
                                        .foregroundStyle(StayTokens.brandPrimary.opacity(0.85))
                                }
                                .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous))
                                
                                Text(photo.title)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(StayTokens.ink)
                                    .lineLimit(1)
                                
                                Text(photo.caption)
                                    .font(.system(size: 11))
                                    .foregroundStyle(StayTokens.inkSecondary)
                                    .lineLimit(2)
                            }
                            .padding(10)
                            .background(StayTokens.surface)
                            .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(StayTokens.ground.ignoresSafeArea())
        .navigationTitle("Horaires & Galerie")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRowItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(StayTokens.brandPrimary)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(StayTokens.inkSecondary)
                Text(value)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(StayTokens.ink)
            }
            Spacer()
        }
    }
}
