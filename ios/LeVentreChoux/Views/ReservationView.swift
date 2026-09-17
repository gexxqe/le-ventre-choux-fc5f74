import SwiftUI

public struct ReservationView: View {
    @ObservedObject var store: RestaurantStore
    
    @State private var guestCount: Int = 2
    @State private var selectedDate: Date = Date()
    @State private var selectedTimeSlot: String = "19:30"
    @State private var customerName: String = ""
    @State private var phoneNumber: String = ""
    @State private var message: String = ""
    
    @State private var isSubmitting: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var validationErrorMessage: String? = nil
    
    private let timeSlots = [
        "12:00", "12:15", "12:30", "12:45", "13:00", "13:15", "13:30",
        "19:00", "19:15", "19:30", "19:45", "20:00", "20:15", "20:30", "21:00"
    ]
    
    public init(store: RestaurantStore) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Header Card
                    headerCard
                    
                    // MARK: - Form Fields
                    VStack(spacing: 16) {
                        // Guests Stepper
                        guestSelectorCard
                        
                        // Date Picker
                        dateSelectorCard
                        
                        // Time Slot Selector
                        timeSlotSelectorCard
                        
                        // Contact Info
                        contactInfoCard
                        
                        // Optional Message
                        messageCard
                    }
                    
                    // Disclosure Note (Demo / Request only)
                    disclosureCard
                    
                    // Error Notice
                    if let err = validationErrorMessage {
                        Text(err)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Submit Button
                    Button {
                        submitReservation()
                    } label: {
                        HStack(spacing: 8) {
                            if isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "envelope.badge.shield.half.filled")
                                Text("Demander une réservation")
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundStyle(StayTokens.inkOnAccent)
                        .background(StayTokens.accentGradient)
                        .clipShape(Capsule())
                        .shadow(color: StayTokens.brandPrimary.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .disabled(isSubmitting)
                    .buttonStyle(.plain)
                    
                    // Quick Call Alternative
                    quickCallSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 36)
            }
            .background(StayTokens.ground.ignoresSafeArea())
            .navigationTitle("Réserver une table")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Demande de réservation envoyée !", isPresented: $showSuccessAlert) {
                Button("Parfait", role: .cancel) {
                    customerName = ""
                    phoneNumber = ""
                    message = ""
                }
            } message: {
                Text("Votre demande a bien été transmise à l'équipe du Ventre à Choux pour le \(selectedDate.formatted(date: .abbreviated, time: .omitted)) à \(selectedTimeSlot). Le restaurant vous confirmera votre table par téléphone sous peu.")
            }
        }
    }
    
    // MARK: - Subviews
    private var headerCard: some View {
        VStack(spacing: 6) {
            Text("Table au Ventre à Choux")
                .font(StayTokens.bistroTitle(20))
                .foregroundStyle(StayTokens.brandPrimary)
            Text("Une table chaleureuse à Montaigu-Vendée. Réservation simple et rapide.")
                .font(.system(size: 13))
                .foregroundStyle(StayTokens.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(StayTokens.groundWarm)
        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
    }
    
    private var guestSelectorCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("NOMBRE DE PERSONNES")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(StayTokens.inkSecondary)
            
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundStyle(StayTokens.brandPrimary)
                
                Text("\(guestCount) \(guestCount > 1 ? "couverts" : "couvert")")
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundStyle(StayTokens.ink)
                
                Spacer()
                
                HStack(spacing: 14) {
                    Button {
                        if guestCount > 1 { guestCount -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(guestCount > 1 ? StayTokens.brandPrimary : Color.gray.opacity(0.4))
                    }
                    .disabled(guestCount <= 1)
                    
                    Text("\(guestCount)")
                        .font(.system(size: 18, weight: .bold))
                        .frame(minWidth: 24)
                    
                    Button {
                        if guestCount < 20 { guestCount += 1 }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(guestCount < 20 ? StayTokens.brandPrimary : Color.gray.opacity(0.4))
                    }
                    .disabled(guestCount >= 20)
                }
            }
        }
        .padding(16)
        .background(StayTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
    }
    
    private var dateSelectorCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DATE DU REPAS")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(StayTokens.inkSecondary)
            
            DatePicker(
                "Choisir la date",
                selection: $selectedDate,
                in: Date()...,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .tint(StayTokens.brandPrimary)
        }
        .padding(16)
        .background(StayTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
    }
    
    private var timeSlotSelectorCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("HEURE SOUHAITÉE")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(StayTokens.inkSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(timeSlots, id: \.self) { slot in
                        Button {
                            selectedTimeSlot = slot
                        } label: {
                            Text(slot)
                                .font(.system(size: 13, weight: selectedTimeSlot == slot ? .bold : .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .foregroundStyle(selectedTimeSlot == slot ? StayTokens.inkOnAccent : StayTokens.ink)
                                .background(selectedTimeSlot == slot ? StayTokens.brandPrimary : StayTokens.surfaceSoft)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .background(StayTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
    }
    
    private var contactInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("VOS COORDONNÉES")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(StayTokens.inkSecondary)
            
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundStyle(StayTokens.brandPrimary)
                        .frame(width: 20)
                    TextField("Votre nom et prénom *", text: $customerName)
                        .font(.system(size: 14))
                }
                .padding(12)
                .background(StayTokens.surfaceSoft)
                .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous))
                
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundStyle(StayTokens.brandPrimary)
                        .frame(width: 20)
                    TextField("Numéro de téléphone *", text: $phoneNumber)
                        .font(.system(size: 14))
                        .keyboardType(.phonePad)
                }
                .padding(12)
                .background(StayTokens.surfaceSoft)
                .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous))
            }
        }
        .padding(16)
        .background(StayTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
    }
    
    private var messageCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MESSAGE OU REMARQUE (OPTIONNEL)")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(StayTokens.inkSecondary)
            
            TextField("Régime particulier, chaise haute, anniversaire...", text: $message, axis: .vertical)
                .lineLimit(3...4)
                .font(.system(size: 14))
                .padding(12)
                .background(StayTokens.surfaceSoft)
                .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous))
        }
        .padding(16)
        .background(StayTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: StayTokens.radiusCard, style: .continuous).stroke(StayTokens.hairline, lineWidth: 1))
    }
    
    private var disclosureCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(StayTokens.accent)
                .font(.system(size: 16))
            
            VStack(alignment: .leading, spacing: 3) {
                Text("Information sur la réservation")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(StayTokens.ink)
                Text("Ceci est une demande de réservation. Votre table sera validée dès que l'équipe du restaurant vous aura contacté par téléphone.")
                    .font(.system(size: 12))
                    .foregroundStyle(StayTokens.inkSecondary)
            }
        }
        .padding(14)
        .background(StayTokens.surfaceSoft)
        .clipShape(RoundedRectangle(cornerRadius: StayTokens.radiusField, style: .continuous))
    }
    
    private var quickCallSection: some View {
        VStack(spacing: 8) {
            Text("Besoin d'une confirmation immédiate ?")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(StayTokens.inkSecondary)
            
            Button {
                let cleanPhone = store.profile.phoneNumber.filter { "0123456789+".contains($0) }
                if let url = URL(string: "tel://\(cleanPhone)") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "phone.fill")
                    Text("Appeler directement le \(store.profile.phoneNumber)")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(StayTokens.brandPrimary)
            }
        }
        .padding(.top, 4)
    }
    
    private func submitReservation() {
        if customerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrorMessage = "Veuillez renseigner votre nom."
            return
        }
        if phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrorMessage = "Veuillez renseigner votre numéro de téléphone."
            return
        }
        
        validationErrorMessage = nil
        isSubmitting = true
        
        // Emulate sending and storing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let newReq = ReservationRequest(
                guestCount: guestCount,
                date: selectedDate,
                timeSlot: selectedTimeSlot,
                customerName: customerName.trimmingCharacters(in: .whitespacesAndNewlines),
                phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                message: message.trimmingCharacters(in: .whitespacesAndNewlines),
                status: .pending,
                createdAt: Date()
            )
            store.addReservation(newReq)
            isSubmitting = false
            showSuccessAlert = true
        }
    }
}
