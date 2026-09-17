import SwiftUI
import Combine

// MARK: - App State & Store

@MainActor
public final class RestaurantStore: ObservableObject {
    public static let shared = RestaurantStore()
    
    @Published public var profile: RestaurantProfile
    @Published public var menuItems: [MenuItem]
    @Published public var openingHours: [WeeklyOpeningHours]
    @Published public var photos: [RestaurantPhoto]
    @Published public var reviews: [CustomerReview]
    @Published public var reservations: [ReservationRequest]
    @Published public var isAdminAuthenticated: Bool = false
    
    private let profileKey = "lvac_profile_key"
    private let menuKey = "lvac_menu_key"
    private let hoursKey = "lvac_hours_key"
    private let photosKey = "lvac_photos_key"
    private let reviewsKey = "lvac_reviews_key"
    private let reservationsKey = "lvac_reservations_key"
    
    public init() {
        // Defaults
        self.profile = RestaurantProfile.standard
        self.menuItems = RestaurantStore.defaultMenuItems()
        self.openingHours = RestaurantStore.defaultHours()
        self.photos = RestaurantStore.defaultPhotos()
        self.reviews = RestaurantStore.defaultReviews()
        self.reservations = RestaurantStore.defaultReservations()
        
        loadPersistedData()
    }
    
    // MARK: - Open / Closed Logic
    public var currentStatusText: (status: String, detail: String, isOpen: Bool) {
        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now) // 1=Sunday, 2=Monday, ..., 7=Saturday
        
        // Map 1..7 to French day index
        let dayIdx: Int
        switch weekday {
        case 2: dayIdx = 0 // Lundi
        case 3: dayIdx = 1 // Mardi
        case 4: dayIdx = 2 // Mercredi
        case 5: dayIdx = 3 // Jeudi
        case 6: dayIdx = 4 // Vendredi
        case 7: dayIdx = 5 // Samedi
        case 1: dayIdx = 6 // Dimanche
        default: dayIdx = 0
        }
        
        guard dayIdx < openingHours.count else {
            return ("Fermé", "Consultez nos horaires", false)
        }
        
        let todayHours = openingHours[dayIdx]
        if todayHours.isClosed {
            return ("Fermé aujourd'hui", "Réouverture prochain jour ouvré", false)
        }
        
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let currentMinutes = hour * 60 + minute
        
        // Parse lunch
        let (lStart, lEnd) = (parseTime(todayHours.lunchStart), parseTime(todayHours.lunchEnd))
        let (dStart, dEnd) = (parseTime(todayHours.dinnerStart), parseTime(todayHours.dinnerEnd))
        
        if currentMinutes >= lStart && currentMinutes < lEnd {
            return ("Ouvert maintenant", "Service du midi jusqu'à \(todayHours.lunchEnd)", true)
        } else if currentMinutes >= dStart && currentMinutes < dEnd {
            return ("Ouvert maintenant", "Service du soir jusqu'à \(todayHours.dinnerEnd)", true)
        } else if currentMinutes < lStart {
            return ("Fermé", "Ouvre à \(todayHours.lunchStart) pour le déjeuner", false)
        } else if currentMinutes >= lEnd && currentMinutes < dStart {
            return ("Fermé", "Ouvre à \(todayHours.dinnerStart) pour le dîner", false)
        } else {
            return ("Fermé", "Fermé pour la nuit", false)
        }
    }
    
    private func parseTime(_ timeStr: String) -> Int {
        let parts = timeStr.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return 0 }
        return parts[0] * 60 + parts[1]
    }
    
    // MARK: - Actions
    public func addReservation(_ req: ReservationRequest) {
        reservations.insert(req, at: 0)
        persistReservations()
    }
    
    public func updateReservationStatus(id: UUID, status: ReservationStatus) {
        if let idx = reservations.firstIndex(where: { $0.id == id }) {
            reservations[idx].status = status
            persistReservations()
        }
    }
    
    public func deleteReservation(id: UUID) {
        reservations.removeAll(where: { $0.id == id })
        persistReservations()
    }
    
    public func saveMenuItem(_ item: MenuItem) {
        if let idx = menuItems.firstIndex(where: { $0.id == item.id }) {
            menuItems[idx] = item
        } else {
            menuItems.append(item)
        }
        persistMenu()
    }
    
    public func deleteMenuItem(id: UUID) {
        menuItems.removeAll(where: { $0.id == id })
        persistMenu()
    }
    
    public func saveProfile(_ p: RestaurantProfile) {
        profile = p
        persistProfile()
    }
    
    public func saveHours(_ h: [WeeklyOpeningHours]) {
        openingHours = h
        persistHours()
    }
    
    public func savePhoto(_ p: RestaurantPhoto) {
        if let idx = photos.firstIndex(where: { $0.id == p.id }) {
            photos[idx] = p
        } else {
            photos.append(p)
        }
        persistPhotos()
    }
    
    public func deletePhoto(id: UUID) {
        photos.removeAll(where: { $0.id == id })
        persistPhotos()
    }
    
    public func resetToDefaults() {
        profile = RestaurantProfile.standard
        menuItems = RestaurantStore.defaultMenuItems()
        openingHours = RestaurantStore.defaultHours()
        photos = RestaurantStore.defaultPhotos()
        reviews = RestaurantStore.defaultReviews()
        reservations = RestaurantStore.defaultReservations()
        
        persistProfile()
        persistMenu()
        persistHours()
        persistPhotos()
        persistReviews()
        persistReservations()
    }
    
    // MARK: - Persistence
    private func persistProfile() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }
    
    private func persistMenu() {
        if let data = try? JSONEncoder().encode(menuItems) {
            UserDefaults.standard.set(data, forKey: menuKey)
        }
    }
    
    private func persistHours() {
        if let data = try? JSONEncoder().encode(openingHours) {
            UserDefaults.standard.set(data, forKey: hoursKey)
        }
    }
    
    private func persistPhotos() {
        if let data = try? JSONEncoder().encode(photos) {
            UserDefaults.standard.set(data, forKey: photosKey)
        }
    }
    
    private func persistReviews() {
        if let data = try? JSONEncoder().encode(reviews) {
            UserDefaults.standard.set(data, forKey: reviewsKey)
        }
    }
    
    private func persistReservations() {
        if let data = try? JSONEncoder().encode(reservations) {
            UserDefaults.standard.set(data, forKey: reservationsKey)
        }
    }
    
    private func loadPersistedData() {
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let saved = try? JSONDecoder().decode(RestaurantProfile.self, from: data) {
            profile = saved
        }
        if let data = UserDefaults.standard.data(forKey: menuKey),
           let saved = try? JSONDecoder().decode([MenuItem].self, from: data) {
            menuItems = saved
        }
        if let data = UserDefaults.standard.data(forKey: hoursKey),
           let saved = try? JSONDecoder().decode([WeeklyOpeningHours].self, from: data) {
            openingHours = saved
        }
        if let data = UserDefaults.standard.data(forKey: photosKey),
           let saved = try? JSONDecoder().decode([RestaurantPhoto].self, from: data) {
            photos = saved
        }
        if let data = UserDefaults.standard.data(forKey: reviewsKey),
           let saved = try? JSONDecoder().decode([CustomerReview].self, from: data) {
            reviews = saved
        }
        if let data = UserDefaults.standard.data(forKey: reservationsKey),
           let saved = try? JSONDecoder().decode([ReservationRequest].self, from: data) {
            reservations = saved
        }
    }
    
    // MARK: - Default Seeded Placeholders
    public static func defaultMenuItems() -> [MenuItem] {
        [
            // Plat du jour
            MenuItem(
                name: "Plat du jour du Chef",
                itemDescription: "Cuisiné chaque matin avec les ingrédients frais du marché vendéen. Exemple : Rôti de porc aux herbes, gratin dauphinois maison.",
                price: 14.50,
                category: .plats,
                isVegetarian: false,
                isAvailable: true,
                isDailySpecial: true,
                photoSymbol: "flame"
            ),
            // Formules
            MenuItem(
                name: "Formule Midi Express",
                itemDescription: "Entrée + Plat ou Plat + Dessert + Café. Idéal pour un déjeuner rapide et savoureux.",
                price: 16.90,
                category: .formules,
                isVegetarian: false,
                isAvailable: true,
                photoSymbol: "fork.knife"
            ),
            MenuItem(
                name: "Formule Complète Vendéenne",
                itemDescription: "Entrée + Plat + Dessert au choix parmi notre sélection de saison.",
                price: 21.50,
                category: .formules,
                isVegetarian: false,
                isAvailable: true,
                photoSymbol: "star"
            ),
            // Entrées
            MenuItem(
                name: "Salade de chèvre chaud vendéen",
                itemDescription: "Toasts de chèvre affiné, miel local, noix croquantes et mesclun frais.",
                price: 7.50,
                category: .entrees,
                isVegetarian: true,
                isAvailable: true,
                photoSymbol: "leaf"
            ),
            MenuItem(
                name: "Terrine maison au poivre vert",
                itemDescription: "Recette traditionnelle de campagne, servie avec cornichons et pain de campagne grillé.",
                price: 6.90,
                category: .entrees,
                isVegetarian: false,
                isAvailable: true,
                photoSymbol: "takeoutbag.and.cup.and.straw"
            ),
            // Plats
            MenuItem(
                name: "Bavette d'aloyau poêlée aux échalotes",
                itemDescription: "Viande française sélectionnée, sauce aux échalotes confites, frites maison croustillantes.",
                price: 17.50,
                category: .plats,
                isVegetarian: false,
                isAvailable: true,
                photoSymbol: "flame.fill"
            ),
            MenuItem(
                name: "Filet de poisson du marché au beurre blanc",
                itemDescription: "Poisson selon arrivage de la côte Atlantique, riz pilaf et légumes glacés.",
                price: 18.00,
                category: .plats,
                isVegetarian: false,
                isAvailable: true,
                photoSymbol: "fish"
            ),
            // Options végétariennes
            MenuItem(
                name: "Omelette végétarienne aux herbes et champignons",
                itemDescription: "Omelette baveuse aux œufs plein air, champignons de Paris persillés, oignons doux et salade.",
                price: 13.50,
                category: .vegetarien,
                isVegetarian: true,
                isAvailable: true,
                photoSymbol: "carrot"
            ),
            MenuItem(
                name: "Poêlée maraîchère et écrasé de pommes de terre",
                itemDescription: "Légumes de saison rôtis aux aromates, huile d'olive vierge et noisettes torréfiées.",
                price: 14.00,
                category: .vegetarien,
                isVegetarian: true,
                isAvailable: true,
                photoSymbol: "leaf.fill"
            ),
            // Desserts
            MenuItem(
                name: "Brioche vendéenne perdue au caramel beurre salé",
                itemDescription: "Spécialité locale dorée minute, boule de glace vanille artisanale.",
                price: 6.80,
                category: .desserts,
                isVegetarian: true,
                isAvailable: true,
                photoSymbol: "birthday.cake"
            ),
            MenuItem(
                name: "Tarte tatin tiède et crème fraîche d'Isigny",
                itemDescription: "Pommes fondantes caramélisées, pâte feuilletée pur beurre.",
                price: 6.50,
                category: .desserts,
                isVegetarian: true,
                isAvailable: true,
                photoSymbol: "heart"
            ),
            // Boissons
            MenuItem(
                name: "Café expresso ou noisette",
                itemDescription: "Pur arabica torréfié artisanalement.",
                price: 1.80,
                category: .boissons,
                isVegetarian: true,
                isAvailable: true,
                photoSymbol: "cup.and.saucer"
            ),
            MenuItem(
                name: "Verre de vin des Fiefs Vendéens (AOC)",
                itemDescription: "Sélection rouge ou blanc d'un domaine local partenaire.",
                price: 4.20,
                category: .boissons,
                isVegetarian: true,
                isAvailable: true,
                photoSymbol: "wineglass"
            )
        ]
    }
    
    public static func defaultHours() -> [WeeklyOpeningHours] {
        [
            WeeklyOpeningHours(dayName: "Lundi", isClosed: false, lunchStart: "12:00", lunchEnd: "14:00", dinnerStart: "19:00", dinnerEnd: "22:00"),
            WeeklyOpeningHours(dayName: "Mardi", isClosed: false, lunchStart: "12:00", lunchEnd: "14:00", dinnerStart: "19:00", dinnerEnd: "22:00"),
            WeeklyOpeningHours(dayName: "Mercredi", isClosed: false, lunchStart: "12:00", lunchEnd: "14:00", dinnerStart: "19:00", dinnerEnd: "22:00"),
            WeeklyOpeningHours(dayName: "Jeudi", isClosed: false, lunchStart: "12:00", lunchEnd: "14:00", dinnerStart: "19:00", dinnerEnd: "22:00"),
            WeeklyOpeningHours(dayName: "Vendredi", isClosed: false, lunchStart: "12:00", lunchEnd: "14:00", dinnerStart: "19:00", dinnerEnd: "22:30"),
            WeeklyOpeningHours(dayName: "Samedi", isClosed: false, lunchStart: "12:00", lunchEnd: "14:30", dinnerStart: "19:00", dinnerEnd: "23:00"),
            WeeklyOpeningHours(dayName: "Dimanche", isClosed: true, lunchStart: "12:00", lunchEnd: "14:00", dinnerStart: "19:00", dinnerEnd: "22:00")
        ]
    }
    
    public static func defaultPhotos() -> [RestaurantPhoto] {
        [
            RestaurantPhoto(title: "Façade & Terrasse", category: "Extérieur", systemIcon: "building.2.fill", caption: "5 Place de la République, vue sur la place principale"),
            RestaurantPhoto(title: "Salle de restaurant", category: "Intérieur", systemIcon: "table.furniture.fill", caption: "Cadre convivial, nappes et boiseries chaleureuses"),
            RestaurantPhoto(title: "Omelette végétarienne", category: "Cuisine", systemIcon: "carrot.fill", caption: "Notre spécialité maison aux œufs frais et fines herbes"),
            RestaurantPhoto(title: "Plat mijoté du jour", category: "Cuisine", systemIcon: "fork.knife", caption: "Préparé chaque matin par notre chef"),
            RestaurantPhoto(title: "Brioche perdue", category: "Desserts", systemIcon: "birthday.cake.fill", caption: "Gourmandise vendéenne au caramel beurre salé"),
            RestaurantPhoto(title: "L'équipe en salle", category: "Équipe", systemIcon: "person.2.fill", caption: "Accueil souriant, service rapide et attentionné")
        ]
    }
    
    public static func defaultReviews() -> [CustomerReview] {
        [
            CustomerReview(authorName: "Client Google vérifié", rating: 5, dateText: "Il y a 2 semaines", comment: "Accueil très chaleureux et souriant. Les plats sont faits maison et généreux. L'omelette végétarienne est excellente et le service rapide !", tag: "Accueil & Service"),
            CustomerReview(authorName: "Habitué de Montaigu", rating: 5, dateText: "Il y a 1 mois", comment: "Un vrai restaurant de cuisine française traditionnelle avec un rapport qualité/prix imbattable. Très bonne adresse sur la Place de la République.", tag: "Qualité & Prix"),
            CustomerReview(authorName: "Visiteur en Vendée", rating: 5, dateText: "Il y a 2 mois", comment: "Ambiance très agréable, équipe aux petits soins. Ingrédients frais et portions copieuses. On reviendra avec grand plaisir !", tag: "Fraîcheur & Ambiance"),
            CustomerReview(authorName: "Client local", rating: 4, dateText: "Il y a 3 mois", comment: "Très bon déjeuner du midi, formule rapide et efficace. Restaurant propre et service courtois.", tag: "Propreté & Rapidité")
        ]
    }
    
    public static func defaultReservations() -> [ReservationRequest] {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        
        return [
            ReservationRequest(
                guestCount: 4,
                date: tomorrow,
                timeSlot: "19:45",
                customerName: "Marie Dupont",
                phoneNumber: "06 12 34 56 78",
                message: "Table près de la fenêtre si possible. Merci !",
                status: .pending,
                createdAt: today
            ),
            ReservationRequest(
                guestCount: 2,
                date: today,
                timeSlot: "12:30",
                customerName: "Thomas Martin",
                phoneNumber: "06 98 76 54 32",
                message: "Déjeuner rapide pour 2 personnes.",
                status: .confirmed,
                createdAt: today
            )
        ]
    }
}
