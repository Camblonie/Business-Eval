//
//  BusinessOwnerSelectorView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/29/25.
//

import SwiftUI
import SwiftData

struct BusinessOwnerSelectorView: View {
    let business: Business
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Owner.name, order: .forward) private var owners: [Owner]
    @State private var showingAddOwner = false
    
    private var availableOwners: [Owner] {
        owners.filter { $0.id != business.owner?.id }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with add button
                HStack {
                    Text("Select Owner")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: { showingAddOwner = true }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("New Owner")
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding()
                
                // Content
                if availableOwners.isEmpty {
                    emptyStateView
                } else {
                    ownersList
                }
            }
            .navigationTitle("Assign Owner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddOwner) {
                AddOwnerViewForBusiness(business: business)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No existing owners")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Create a new owner to assign to this business")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Create New Owner") {
                showingAddOwner = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var ownersList: some View {
        List {
            ForEach(availableOwners) { owner in
                BusinessOwnerSelectionRow(owner: owner) {
                    assignOwner(owner)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func assignOwner(_ owner: Owner) {
        // Remove business from current owner if exists
        if let currentOwner = business.owner {
            currentOwner.businesses.removeAll { $0.id == business.id }
        }
        
        // Assign new owner
        business.owner = owner
        owner.businesses.append(business)
        
        dismiss()
    }
}

struct BusinessOwnerSelectionRow: View {
    let owner: Owner
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(owner.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if let title = owner.title {
                        Text(title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let email = owner.email {
                        Text(email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("\(owner.businesses.count) business\(owner.businesses.count == 1 ? "" : "es")")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(owner.contactPreference.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(contactPreferenceColor.opacity(0.2))
                            .foregroundColor(contactPreferenceColor)
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var contactPreferenceColor: Color {
        switch owner.contactPreference {
        case .email: return .blue
        case .phone: return .green
        case .text: return .orange
        case .either: return .purple
        }
    }
}

// Specialized AddOwnerView for business context
struct AddOwnerViewForBusiness: View {
    let business: Business
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var title = ""
    @State private var notes = ""
    @State private var contactPreference: ContactPreference = .email
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Information Section
                Section("Basic Information") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.words)
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
                
                // Notes Section
                Section("Notes") {
                    TextField("Additional notes about this owner...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Owner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create & Assign") {
                        createAndAssignOwner()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func createAndAssignOwner() {
        let owner = Owner(
            name: name,
            email: email.isEmpty ? nil : email,
            phone: phone.isEmpty ? nil : phone,
            title: title.isEmpty ? nil : title,
            notes: notes.isEmpty ? nil : notes
        )
        owner.contactPreference = contactPreference
        
        // Assign to business
        business.owner = owner
        owner.businesses.append(business)
        
        modelContext.insert(owner)
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
    
    return BusinessOwnerSelectorView(business: business)
        .modelContainer(for: [Owner.self, Business.self], inMemory: true)
}
