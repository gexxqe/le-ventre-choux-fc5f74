import SwiftUI

public struct AdminView: View {
    @ObservedObject var store: RestaurantStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var isAuthenticated: Bool = true // Direct mobile-friendly access or PIN unlock
    @State private var selectedAdminTab: AdminSection = .reservations
    @State private var showingEditProfile = false
    @State private var showingAddDishSheet = false
    @State private var editingMenuItem: MenuItem? = nil
    
    public enum AdminSection: String, CaseIterable, Identifiable {
        case reservations = "Réservations"
        case menu = "Carte & Plats"
        case hours = "Horaires"
        case info = "Infos & Contact"
        
        public var id: String { rawValue }
        
        public var icon: String {
            switch self {
            case .reservations: return "envelope.badge"
            case .menu: return "fork.knife"
            case .hours: return "clock"
            case .info: return "building.2"
            }
        }
    }
    
    public init(store: RestaurantStore) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Admin Section Segmented Bar
                adminSegmentedBar
                
                // MARK: - Content by Section
                ScrollView {
                    VStack(spacing: 16) {
                        switch selectedAdminTab {
                        case .reservations:
                            adminReservationsSection
                        case .menu:
                            adminMenuSection
                        case .hours:
                            adminHoursSection
                        case .info:
                            adminInfoSection
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 36)
                }
            }
            .background(StayTokens.ground.ignoresSafeArea())
            .navigationTitle("Espace Restaurateur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Quitter") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(StayTokens.brandPrimary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if selectedAdminTab == .menu {
                        Button {
                            editingMenuItem = MenuItem(
                                name: "",
                                itemDescription: "",
                                price: 15.0,
                                category: .plats,
                                isVegetarian: false,
                                isAvailable: true,
                                isDailySpecial: false,
                                isCustom: true
                            )
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text("Nouveau plat")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(StayTokens.brandPrimary)
                        }
                    }
                }
            }
            .sheet(item: $editingMenuItem) { item in
                EditDishSheet(store: store, item: item)
            }
        }
    }
    
    // MARK: - Admin Segmented Bar
    private var adminSegmentedBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AdminSection.allCases) { section in
                    Button {
                        selectedAdminTab = section
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: section.icon)
                            Text(section.rawValue)
                                .font(.system(size: 13, weight: selectedAdminTab == section ? .bold : .medium))
                            
                            if section == .reservations && !store.reservations.filter({ $0.status == .pending }).isEmpty {
                                Text("\(store.reservations.filter({ $0.status == .pending }).count)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.red)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundStyle(selectedAdminTab == section ? StayTokens.inkOnAccent : StayTokens.ink)
                        .background(
                            selectedAdminTab == section ? AnyShapeStyle(StayTokens.brandPrimary) : AnyShapeStyle(StayTokens.surface)
                        )
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(selectedAdminTab == section ? Color.clear : StayTokens.hairline, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(StayTokens.surfaceSoft.opacity(0.6))
        .overlay(Divider(), alignment: .bottom)
    }
    
    // MARK: - Admin Reservations
    private var adminReservationsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("DEMANDES DE RÉSERVATION (\(store.reservations.count))")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.0)
                    .foregroundStyle(StayTokens.inkSecondary)
                
                Spacer()
                
                Text("Stockage local sécurisé")
                    .font(.system(size: 11))
                    .foregroundStyle(StayTokens.accent)
            }
            
            if store.reservations.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.system(size: 36))
                        .foregroundStyle(StayTokens.inkSecondary)
                    Text("Aucune demande de réservation")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(StayTokens.ink)
                }
                .padding(32)
                .frame(maxWidth: .infinity)
                .background(StayTokens.surface)
                .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
            } else {
                ForEach(store.reservations) { req in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(req.customerName)
                                    .font(.system(size: 16, weight: .bold, design: .serif))
                                    .foregroundStyle(StayTokens.ink)
                                
                                Text("\(req.guestCount) personnes • \(req.date.formatted(date: .abbreviated, time: .omitted)) à \(req.timeSlot)")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(StayTokens.brandPrimary)
                            }
                            Spacer()
                            
                            // Status Pill
                            Text(req.status.rawValue)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(req.status == .confirmed ? StayTokens.positive : (req.status == .pending ? StayTokens.accent : Color.red))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background((req.status == .confirmed ? StayTokens.positive : (req.status == .pending ? StayTokens.accent : Color.red)).opacity(0.12))
                                .clipShape(Capsule())
                        }
                        
                        // Contact phone button
                        Button {
                            let clean = req.phoneNumber.filter { "0123456789+".contains($0) }
                            if let url = URL(string: "tel://\(clean)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "phone.fill")
                                    .font(.caption)
                                Text("Appeler \(req.phoneNumber)")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundStyle(StayTokens.brandPrimary)
                        }
                        
                        if !req.message.isEmpty {
                            Text("« \(req.message) »")
                                .font(.system(size: 12))
                                .italic()
                                .foregroundStyle(StayTokens.inkSecondary)
                                .padding(8)
                                .background(StayTokens.surfaceSoft)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        
                        Divider()
                        
                        // Status action buttons
                        HStack(spacing: 8) {
                            Button {
                                store.updateReservationStatus(id: req.id, status: .confirmed)
                            } label: {
                                Text("Confirmer")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(StayTokens.positive)
                                    .clipShape(Capsule())
                            }
                            
                            Button {
                                store.updateReservationStatus(id: req.id, status: .declined)
                            } label: {
                                Text("Refuser")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.red)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.red.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            
                            Spacer()
                            
                            Button {
                                store.deleteReservation(id: req.id)
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 13))
                                    .foregroundStyle(StayTokens.inkSecondary)
                            }
                        }
                    }
                    .padding(14)
                    .background(StayTokens.surface)
                    .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
                }
            }
        }
    }
    
    // MARK: - Admin Menu Section
    private var adminMenuSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("GESTION DE LA CARTE & PLAT DU JOUR")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.0)
                    .foregroundStyle(StayTokens.inkSecondary)
                
                Spacer()
                
                Text("\(store.menuItems.count) plats")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(StayTokens.brandPrimary)
            }
            
            ForEach(store.menuItems) { item in
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(item.name)
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundStyle(StayTokens.ink)
                            
                            if item.isDailySpecial {
                                Text("Plat du jour")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(StayTokens.accent)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(StayTokens.accent.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                            
                            if item.isVegetarian {
                                Text("Veg")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(StayTokens.positive)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(StayTokens.positive.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
                        
                        Text("\(item.category.rawValue) • \(String(format: "%.2f €", item.price))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(StayTokens.inkSecondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        editingMenuItem = item
                    } label: {
                        Text("Modifier")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(StayTokens.brandPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(StayTokens.surfaceSoft)
                            .clipShape(Capsule())
                    }
                }
                .padding(12)
                .background(StayTokens.surface)
                .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
            }
        }
    }
    
    // MARK: - Admin Hours Section
    private var adminHoursSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("MODIFICATION DES HORAIRES HEBDOMADAIRES")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(StayTokens.inkSecondary)
            
            ForEach(0..<store.openingHours.count, id: \.self) { index in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(store.openingHours[index].dayName)
                            .font(.system(size: 15, weight: .bold, design: .serif))
                            .foregroundStyle(StayTokens.brandPrimary)
                        
                        Spacer()
                        
                        Toggle("Fermé", isOn: $store.openingHours[index].isClosed)
                            .labelsHidden()
                            .tint(StayTokens.brandPrimary)
                        
                        Text(store.openingHours[index].isClosed ? "Fermé" : "Ouvert")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(store.openingHours[index].isClosed ? Color.red : StayTokens.positive)
                    }
                    
                    if !store.openingHours[index].isClosed {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Midi :")
                                    .font(.system(size: 11))
                                    .foregroundStyle(StayTokens.inkSecondary)
                                HStack {
                                    TextField("12:00", text: $store.openingHours[index].lunchStart)
                                        .font(.system(size: 12))
                                        .frame(width: 44)
                                    Text("-")
                                    TextField("14:00", text: $store.openingHours[index].lunchEnd)
                                        .font(.system(size: 12))
                                        .frame(width: 44)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Soir :")
                                    .font(.system(size: 11))
                                    .foregroundStyle(StayTokens.inkSecondary)
                                HStack {
                                    TextField("19:00", text: $store.openingHours[index].dinnerStart)
                                        .font(.system(size: 12))
                                        .frame(width: 44)
                                    Text("-")
                                    TextField("22:00", text: $store.openingHours[index].dinnerEnd)
                                        .font(.system(size: 12))
                                        .frame(width: 44)
                                }
                            }
                        }
                        .padding(8)
                        .background(StayTokens.surfaceSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
                .padding(12)
                .background(StayTokens.surface)
                .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
            }
            
            Button {
                store.saveHours(store.openingHours)
            } label: {
                Text("Enregistrer les horaires")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(StayTokens.inkOnAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(StayTokens.brandPrimary)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Admin Info Section
    private var adminInfoSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("COORDONNÉES & TEXTES DU RESTAURANT")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(StayTokens.inkSecondary)
            
            VStack(spacing: 12) {
                AdminTextFieldRow(title: "Nom du restaurant", text: $store.profile.name)
                AdminTextFieldRow(title: "Sous-titre / Slogan", text: $store.profile.tagline)
                AdminTextFieldRow(title: "Adresse", text: $store.profile.address)
                AdminTextFieldRow(title: "Code Postal & Ville", text: $store.profile.postalCodeCity)
                AdminTextFieldRow(title: "Téléphone", text: $store.profile.phoneNumber)
                AdminTextFieldRow(title: "Lien Page Facebook", text: $store.profile.facebookURL)
                AdminTextFieldRow(title: "Email de contact", text: $store.profile.emailNotice)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Texte de présentation (Notre cuisine)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(StayTokens.inkSecondary)
                    TextField("Présentation", text: $store.profile.introStory, axis: .vertical)
                        .lineLimit(4...6)
                        .font(.system(size: 13))
                        .padding(10)
                        .background(StayTokens.surfaceSoft)
                        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous))
                }
            }
            .padding(14)
            .background(StayTokens.surface)
            .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
            
            Button {
                store.saveProfile(store.profile)
            } label: {
                Text("Enregistrer les coordonnées")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(StayTokens.inkOnAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(StayTokens.brandPrimary)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            
            // Reset to demo defaults button
            Button {
                store.resetToDefaults()
            } label: {
                Text("Réinitialiser les données de démonstration")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(StayTokens.inkSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
            }
        }
    }
}

// MARK: - Subcomponents
struct AdminTextFieldRow: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(StayTokens.inkSecondary)
            TextField(title, text: $text)
                .font(.system(size: 14))
                .padding(10)
                .background(StayTokens.surfaceSoft)
                .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous))
        }
    }
}

// MARK: - Edit Dish Sheet
struct EditDishSheet: View {
    @ObservedObject var store: RestaurantStore
    @State var item: MenuItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informations du plat") {
                    TextField("Nom du plat", text: $item.name)
                    TextField("Description & Ingrédients", text: $item.itemDescription, axis: .vertical)
                        .lineLimit(2...4)
                    
                    HStack {
                        Text("Prix (€)")
                        Spacer()
                        TextField("Prix", value: $item.price, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Catégorie & Options") {
                    Picker("Catégorie", selection: $item.category) {
                        ForEach(MenuCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    
                    Toggle("Option Végétarienne", isOn: $item.isVegetarian)
                    Toggle("Plat du jour", isOn: $item.isDailySpecial)
                    Toggle("Disponible en salle", isOn: $item.isAvailable)
                }
                
                Section {
                    Button {
                        store.saveMenuItem(item)
                        dismiss()
                    } label: {
                        Text("Enregistrer le plat")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(StayTokens.brandPrimary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    if store.menuItems.contains(where: { $0.id == item.id }) {
                        Button(role: .destructive) {
                            store.deleteMenuItem(id: item.id)
                            dismiss()
                        } label: {
                            Text("Supprimer ce plat")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .navigationTitle(item.name.isEmpty ? "Nouveau plat" : "Modifier le plat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
}
