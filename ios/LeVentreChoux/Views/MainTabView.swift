import SwiftUI

public struct MainTabView: View {
    @StateObject private var store = RestaurantStore.shared
    @State private var selectedTab: Int = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(store: store, selectedTab: $selectedTab)
                .tabItem {
                    Label("Accueil", systemImage: "house.fill")
                }
                .tag(0)
            
            MenuView(store: store)
                .tabItem {
                    Label("Menu", systemImage: "fork.knife")
                }
                .tag(1)
            
            ReservationView(store: store)
                .tabItem {
                    Label("Réserver", systemImage: "calendar.badge.clock")
                }
                .tag(2)
            
            ReviewsView(store: store)
                .tabItem {
                    Label("Avis", systemImage: "star.fill")
                }
                .tag(3)
            
            MoreView(store: store, selectedTab: $selectedTab)
                .tabItem {
                    Label("Plus", systemImage: "ellipsis")
                }
                .tag(4)
        }
        .tint(StayTokens.brandPrimary)
        .background(StayTokens.ground.ignoresSafeArea())
    }
}
