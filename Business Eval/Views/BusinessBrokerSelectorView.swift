//
//  BusinessBrokerSelectorView.swift
//  Business Eval
//
//  Created by Scott Campbell on 1/1/26.
//
//  Allows selecting or creating a broker to assign to a business.
//

import SwiftUI
import SwiftData

struct BusinessBrokerSelectorView: View {
    let business: Business
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Broker.name, order: .forward) private var brokers: [Broker]
    @State private var showingAddBroker = false
    
    // Filter out the current broker if one exists
    private var availableBrokers: [Broker] {
        brokers.filter { $0.id != business.broker?.id }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with add button
                HStack {
                    Text("Select Broker")
                        .font(AppTheme.Fonts.headline)
                    
                    Spacer()
                    
                    Button(action: { showingAddBroker = true }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("New Broker")
                        }
                        .font(AppTheme.Fonts.caption)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(AppTheme.Colors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(AppTheme.CornerRadius.medium)
                    }
                }
                .padding()
                
                // Content
                if availableBrokers.isEmpty {
                    emptyStateView
                } else {
                    brokersList
                }
            }
            .navigationTitle("Assign Broker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddBroker) {
                AddBrokerViewForBusiness(business: business)
            }
        }
    }
    
    private var emptyStateView: some View {
        EmptyStateView(
            icon: "briefcase",
            title: "No existing brokers",
            message: "Create a new broker to assign to this business",
            actionTitle: "Create New Broker"
        ) {
            showingAddBroker = true
        }
    }
    
    private var brokersList: some View {
        List {
            ForEach(availableBrokers) { broker in
                BusinessBrokerSelectionRow(broker: broker) {
                    assignBroker(broker)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // Assigns the selected broker to the business
    private func assignBroker(_ broker: Broker) {
        // Remove business from current broker if exists
        if let currentBroker = business.broker {
            currentBroker.businesses.removeAll { $0.id == business.id }
        }
        
        // Assign new broker
        business.broker = broker
        broker.businesses.append(business)
        
        dismiss()
    }
}

// MARK: - Broker Selection Row
struct BusinessBrokerSelectionRow: View {
    let broker: Broker
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(broker.name)
                        .font(AppTheme.Fonts.subheadlineMedium)
                    
                    if let company = broker.company {
                        Text(company)
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                    }
                    
                    if let email = broker.email {
                        Text(email)
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                    }
                    
                    HStack {
                        Text("\(broker.businesses.count) business\(broker.businesses.count == 1 ? "" : "es")")
                            .font(.caption2)
                            .foregroundColor(AppTheme.Colors.secondary)
                        
                        Spacer()
                        
                        if let commission = broker.commission {
                            Text("\(commission, specifier: "%.1f")% commission")
                                .font(.caption2)
                                .padding(.horizontal, AppTheme.Badge.horizontalPadding)
                                .padding(.vertical, AppTheme.Badge.verticalPadding)
                                .background(AppTheme.Colors.money.opacity(0.2))
                                .foregroundColor(AppTheme.Colors.money)
                                .cornerRadius(AppTheme.CornerRadius.small)
                        }
                        
                        StatusBadge(broker.contactPreference.rawValue, color: contactPreferenceColor)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
            .padding(.vertical, AppTheme.Spacing.sm)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var contactPreferenceColor: Color {
        switch broker.contactPreference {
        case .email: return AppTheme.Colors.primary
        case .phone: return AppTheme.Colors.success
        case .text: return AppTheme.Colors.warning
        case .either: return .purple
        }
    }
}

// MARK: - Add Broker View for Business Context
/// Specialized AddBrokerView that creates and assigns a broker to a business
struct AddBrokerViewForBusiness: View {
    let business: Business
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var company = ""
    @State private var license = ""
    @State private var commission: Double?
    @State private var notes = ""
    @State private var contactPreference: ContactPreference = .email
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Information Section
                Section("Basic Information") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Company", text: $company)
                        .textInputAutocapitalization(.words)
                    
                    TextField("License Number", text: $license)
                }
                
                // Contact Information Section
                Section("Contact Information") {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                    
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    
                    Picker("Contact Preference", selection: $contactPreference) {
                        ForEach(ContactPreference.allCases, id: \.self) { preference in
                            Text(preference.rawValue).tag(preference)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Commission Section
                Section("Commission") {
                    TextField("Commission %", value: $commission, format: .number)
                        .keyboardType(.decimalPad)
                }
                
                // Notes Section
                Section("Notes") {
                    TextField("Additional notes about this broker...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Broker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create & Assign") {
                        createAndAssignBroker()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    // Creates a new broker and assigns it to the business
    private func createAndAssignBroker() {
        let broker = Broker(
            name: name,
            email: email.isEmpty ? nil : email,
            phone: phone.isEmpty ? nil : phone,
            company: company.isEmpty ? nil : company,
            license: license.isEmpty ? nil : license,
            commission: commission,
            notes: notes.isEmpty ? nil : notes
        )
        broker.contactPreference = contactPreference
        
        // Assign to business
        business.broker = broker
        broker.businesses.append(business)
        
        modelContext.insert(broker)
        dismiss()
    }
}

#Preview {
    let business = Business(
        name: "Test Business",
        industry: "Technology",
        location: "San Francisco, CA",
        askingPrice: 500000,
        annualRevenue: 1000000,
        annualProfit: 200000,
        numberOfEmployees: 10,
        yearsEstablished: 5,
        businessDescription: "A test business for demonstration purposes."
    )
    
    return BusinessBrokerSelectorView(business: business)
        .modelContainer(for: [Broker.self, Business.self], inMemory: true)
}
