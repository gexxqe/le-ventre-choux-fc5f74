import SwiftUI

public struct MenuView: View {
    @ObservedObject var store: RestaurantStore
    @State private var selectedCategory: MenuCategory = .formules
    @State private var onlyVegetarian: Bool = false
    @State private var selectedItemForDetail: MenuItem? = nil
    
    public init(store: RestaurantStore) {
        self.store = store
    }
    
    var filteredItems: [MenuItem] {
        store.menuItems.filter { item in
            let matchesCategory = item.category == selectedCategory
            let matchesVeg = onlyVegetarian ? item.isVegetarian : true
            return matchesCategory && matchesVeg
        }
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Category Filter Chips
                categoryBar
                
                // MARK: - Menu Item List
                ScrollView {
                    VStack(spacing: 20) {
                        // Daily special highlight if in Plats or Formules
                        if (selectedCategory == .plats || selectedCategory == .formules) && !onlyVegetarian {
                            dailySpecialBanner
                        }
                        
                        // Vegetarian Toggle Pill
                        vegetarianFilterPill
                        
                        // List of items
                        if filteredItems.isEmpty {
                            emptyStateView
                        } else {
                            VStack(spacing: 12) {
                                ForEach(filteredItems) { item in
                                    MenuItemCard(item: item) {
                                        selectedItemForDetail = item
                                    }
                                }
                            }
                        }
                        
                        // Note about fresh products
                        footerNotice
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 32)
                }
            }
            .background(StayTokens.ground.ignoresSafeArea())
            .navigationTitle("La Carte & Formules")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedItemForDetail) { item in
                MenuItemDetailSheet(item: item)
            }
        }
    }
    
    // MARK: - Category Bar
    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MenuCategory.allCases) { cat in
                    Button {
                        selectedCategory = cat
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: cat.iconName)
                                .font(.system(size: 13))
                            Text(cat.rawValue)
                                .font(.system(size: 13, weight: selectedCategory == cat ? .bold : .medium))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .foregroundStyle(selectedCategory == cat ? StayTokens.inkOnAccent : StayTokens.ink)
                        .background(
                            selectedCategory == cat ?
                            AnyShapeStyle(StayTokens.brandPrimary) :
                            AnyShapeStyle(StayTokens.surface)
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(selectedCategory == cat ? Color.clear : StayTokens.hairline, lineWidth: 1)
                        )
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
    
    // MARK: - Vegetarian Filter Pill
    private var vegetarianFilterPill: some View {
        HStack {
            Toggle(isOn: $onlyVegetarian) {
                HStack(spacing: 6) {
                    Image(systemName: "carrot.fill")
                        .foregroundStyle(StayTokens.accent)
                    Text("Options végétariennes uniquement")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(StayTokens.ink)
                }
            }
            .tint(StayTokens.brandPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(StayTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
    }
    
    // MARK: - Daily Special Banner
    private var dailySpecialBanner: some View {
        if let special = store.menuItems.first(where: { $0.isDailySpecial }) {
            return AnyView(
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("PLAT DU JOUR AUJOURD'HUI", systemImage: "sparkles")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(StayTokens.accent)
                        
                        Spacer()
                        
                        Text(String(format: "%.2f €", special.price))
                            .font(.system(size: 16, weight: .bold, design: .serif))
                            .foregroundStyle(StayTokens.brandPrimary)
                    }
                    
                    Text(special.name)
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .foregroundStyle(StayTokens.ink)
                    
                    Text(special.itemDescription)
                        .font(.system(size: 13))
                        .foregroundStyle(StayTokens.inkSecondary)
                }
                .padding(16)
                .background(StayTokens.groundWarm)
                .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous)
                        .stroke(StayTokens.accent.opacity(0.5), lineWidth: 1)
                )
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 40))
                .foregroundStyle(StayTokens.inkSecondary)
            Text("Aucun plat dans cette sélection")
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .foregroundStyle(StayTokens.ink)
            Text("Désactivez le filtre végétarien ou consultez une autre catégorie.")
                .font(.system(size: 13))
                .foregroundStyle(StayTokens.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(StayTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
    }
    
    private var footerNotice: some View {
        VStack(spacing: 6) {
            Text("Cuisine maison & Ingrédients frais")
                .font(.system(size: 12, weight: .bold, design: .serif))
                .foregroundStyle(StayTokens.brandPrimary)
            Text("Tous nos plats sont préparés sur place. Prix nets en euros, taxes et service compris.")
                .font(.system(size: 11))
                .foregroundStyle(StayTokens.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 12)
    }
}

// MARK: - Menu Item Card
struct MenuItemCard: View {
    let item: MenuItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 14) {
                // Dish Icon Thumbnail
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(item.isVegetarian ? Color(red: 0.90, green: 0.94, blue: 0.88) : StayTokens.surfaceSoft)
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: item.photoSymbol)
                        .font(.system(size: 24))
                        .foregroundStyle(item.isVegetarian ? StayTokens.brandPrimary : StayTokens.accent)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        Text(item.name)
                            .font(.system(size: 15, weight: .bold, design: .serif))
                            .foregroundStyle(StayTokens.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                        
                        Text(String(format: "%.2f €", item.price))
                            .font(.system(size: 15, weight: .bold, design: .serif))
                            .foregroundStyle(StayTokens.brandPrimary)
                    }
                    
                    Text(item.itemDescription)
                        .font(.system(size: 13))
                        .foregroundStyle(StayTokens.inkSecondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        if item.isVegetarian {
                            HStack(spacing: 3) {
                                Image(systemName: "carrot.fill")
                                    .font(.caption2)
                                Text("Végétarien")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundStyle(StayTokens.positive)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(StayTokens.positive.opacity(0.12))
                            .clipShape(Capsule())
                        }
                        
                        if item.isDailySpecial {
                            Text("Plat du jour")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(StayTokens.accent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(StayTokens.accent.opacity(0.12))
                                .clipShape(Capsule())
                        }
                        
                        if !item.isAvailable {
                            Text("Épuisé")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color.red)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.top, 2)
                }
            }
            .padding(14)
            .background(StayTokens.surface)
            .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Detail Sheet
struct MenuItemDetailSheet: View {
    let item: MenuItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous)
                            .fill(StayTokens.groundWarm)
                            .frame(height: 160)
                            .overlay(StayScene(paletteIndex: item.isVegetarian ? 1 : 0))
                        
                        Image(systemName: item.photoSymbol)
                            .font(.system(size: 60))
                            .foregroundStyle(StayTokens.brandPrimary)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(item.name)
                                .font(StayTokens.display(22))
                                .foregroundStyle(StayTokens.ink)
                            
                            Spacer()
                            
                            Text(String(format: "%.2f €", item.price))
                                .font(StayTokens.display(22))
                                .foregroundStyle(StayTokens.brandPrimary)
                        }
                        
                        HStack(spacing: 8) {
                            Text(item.category.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(StayTokens.inkSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(StayTokens.surfaceSoft)
                                .clipShape(Capsule())
                            
                            if item.isVegetarian {
                                Label("Option Végétarienne", systemImage: "carrot.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(StayTokens.positive)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(StayTokens.positive.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                        
                        Divider().padding(.vertical, 4)
                        
                        Text("DESCRIPTION & COMPOSITION")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.0)
                            .foregroundStyle(StayTokens.inkSecondary)
                        
                        Text(item.itemDescription)
                            .font(.system(size: 15))
                            .lineSpacing(4)
                            .foregroundStyle(StayTokens.ink)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(StayTokens.accent)
                                Text("Fait maison à Montaigu-Vendée")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(StayTokens.ink)
                            }
                            Text("Préparé avec des ingrédients frais selon la tradition bistrotière.")
                                .font(.system(size: 12))
                                .foregroundStyle(StayTokens.inkSecondary)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(StayTokens.surfaceSoft)
                        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous))
                    }
                }
                .padding(20)
            }
            .background(StayTokens.ground.ignoresSafeArea())
            .navigationTitle("Détail du plat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(StayTokens.brandPrimary)
                }
            }
        }
    }
}
