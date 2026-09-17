import SwiftUI
import Combine

// MARK: - Models

public enum MenuCategory: String, CaseIterable, Codable, Identifiable {
    case formules = "Formules"
    case entrees = "Entrées"
    case plats = "Plats"
    case vegetarien = "Options végétariennes"
    case desserts = "Desserts"
    case boissons = "Boissons"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .formules: return "fork.knife"
        case .entrees: return "leaf"
        case .plats: return "flame"
        case .vegetarien: return "carrot"
        case .desserts: return "birthday.cake"
        case .boissons: return "wineglass"
        }
    }
}

public struct MenuItem: Identifiable, Codable, Equatable {
    public var id: UUID
    public var name: String
    public var itemDescription: String
    public var price: Double
    public var category: MenuCategory
    public var isVegetarian: Bool
    public var isAvailable: Bool
    public var isDailySpecial: Bool
    public var photoSymbol: String
    public var isCustom: Bool
    
    public init(
        id: UUID = UUID(),
        name: String,
        itemDescription: String,
        price: Double,
        category: MenuCategory,
        isVegetarian: Bool = false,
        isAvailable: Bool = true,
        isDailySpecial: Bool = false,
        photoSymbol: String = "fork.knife",
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.itemDescription = itemDescription
        self.price = price
        self.category = category
        self.isVegetarian = isVegetarian
        self.isAvailable = isAvailable
        self.isDailySpecial = isDailySpecial
        self.photoSymbol = photoSymbol
        self.isCustom = isCustom
    }
}

public enum ReservationStatus: String, Codable, CaseIterable {
    case pending = "En attente"
    case confirmed = "Confirmée"
    case declined = "Refusée"
}

public struct ReservationRequest: Identifiable, Codable, Equatable {
    public var id: UUID
    public var guestCount: Int
    public var date: Date
    public var timeSlot: String
    public var customerName: String
    public var phoneNumber: String
    public var message: String
    public var status: ReservationStatus
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        guestCount: Int = 2,
        date: Date = Date(),
        timeSlot: String = "19:30",
        customerName: String = "",
        phoneNumber: String = "",
        message: String = "",
        status: ReservationStatus = .pending,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.guestCount = guestCount
        self.date = date
        self.timeSlot = timeSlot
        self.customerName = customerName
        self.phoneNumber = phoneNumber
        self.message = message
        self.status = status
        self.createdAt = createdAt
    }
}

public struct WeeklyOpeningHours: Codable, Equatable {
    public var dayName: String
    public var isClosed: Bool
    public var lunchStart: String
    public var lunchEnd: String
    public var dinnerStart: String
    public var dinnerEnd: String
    
    public init(dayName: String, isClosed: Bool, lunchStart: String = "12:00", lunchEnd: String = "14:00", dinnerStart: String = "19:00", dinnerEnd: String = "22:00") {
        self.dayName = dayName
        self.isClosed = isClosed
        self.lunchStart = lunchStart
        self.lunchEnd = lunchEnd
        self.dinnerStart = dinnerStart
        self.dinnerEnd = dinnerEnd
    }
}

public struct RestaurantPhoto: Identifiable, Codable, Equatable {
    public var id: UUID
    public var title: String
    public var category: String
    public var systemIcon: String
    public var caption: String
    
    public init(id: UUID = UUID(), title: String, category: String, systemIcon: String, caption: String) {
        self.id = id
        self.title = title
        self.category = category
        self.systemIcon = systemIcon
        self.caption = caption
    }
}

public struct CustomerReview: Identifiable, Codable, Equatable {
    public var id: UUID
    public var authorName: String
    public var rating: Int
    public var dateText: String
    public var comment: String
    public var tag: String
    
    public init(id: UUID = UUID(), authorName: String, rating: Int, dateText: String, comment: String, tag: String) {
        self.id = id
        self.authorName = authorName
        self.rating = rating
        self.dateText = dateText
        self.comment = comment
        self.tag = tag
    }
}

public struct RestaurantProfile: Codable, Equatable {
    public var name: String
    public var tagline: String
    public var address: String
    public var postalCodeCity: String
    public var country: String
    public var phoneNumber: String
    public var facebookURL: String
    public var googleRating: Double
    public var reviewCount: Int
    public var introStory: String
    public var dailySpecialNotice: String
    public var emailNotice: String
    
    public static let standard = RestaurantProfile(
        name: "Le Ventre à Choux",
        tagline: "Restaurant français à Montaigu-Vendée",
        address: "5 Place de la République",
        postalCodeCity: "85600 Montaigu-Vendée",
        country: "France",
        phoneNumber: "02 51 94 00 81",
        facebookURL: "https://www.facebook.com/leventreachoux",
        googleRating: 4.7,
        reviewCount: 78,
        introStory: "Le Ventre à Choux vous accueille au cœur de Montaigu-Vendée dans une ambiance chaleureuse et authentique. Notre cuisine traditionnelle française met à l'honneur les produits frais et le fait maison, avec des formules variées et des options végétariennes savoureuses (dont notre célèbre omelette végétarienne) à prix doux.",
        dailySpecialNotice: "Plat du jour cuisiné chaque matin selon les arrivages du marché vendéen.",
        emailNotice: "contact@leventreachoux.fr"
    )
}
