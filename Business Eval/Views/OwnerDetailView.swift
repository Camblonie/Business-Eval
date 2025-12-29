//
//  OwnerDetailView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData

struct OwnerDetailView: View {
    @Bindable var owner: Owner
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditOwner = false
    @State private var showingAddBusiness = false
    @State private var showingBusinessSelector = false
    
    @Query(sort: \Business.name, order: .forward) private var allBusinesses: [Business]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Owner Information
                ownerInfoSection
                
                // Contact Information
                contactSection
                
                // Businesses
                businessesSection
                
                // Notes
                if let notes = owner.notes, !notes.isEmpty {
                    notesSection
                }
                
                // Quick Actions
                quickActionsSection
            }
            .padding()
        }
        .navigationTitle(owner.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingEditOwner = true }) {
                        Label("Edit Owner", systemImage: "pencil")
                    }
                    
                    if let email = owner.email {
                        Button(action: { sendEmail(to: email) }) {
                            Label("Send Email", systemImage: "envelope")
                        }
                    }
                    
                    if let phone = owner.phone {
                        Button(action: { makeCall(to: phone) }) {
                            Label("Call", systemImage: "phone")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditOwner) {
            EditOwnerView(owner: owner)
        }
    }
    
    private var ownerInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Owner Information")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                if let title = owner.title {
                    DetailRow(label: "Title", value: title)
                }
                
                DetailRow(label: "Contact Preference", value: owner.contactPreference.rawValue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact Information")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                if let email = owner.email {
                    DetailRow(label: "Email", value: email)
                }
                
                if let phone = owner.phone {
                    DetailRow(label: "Phone", value: phone)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var businessesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Associated Businesses")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { showingBusinessSelector = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            
            if owner.businesses.isEmpty {
                VStack(spacing: 12) {
                    Text("No businesses associated")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Add Business") {
                        showingBusinessSelector = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(owner.businesses) { business in
                        BusinessAssociationRow(
                            business: business,
                            onRemove: { removeBusiness(business) }
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $showingBusinessSelector) {
            BusinessSelectorView(owner: owner)
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
                .fontWeight(.bold)
            
            Text(owner.notes!)
                .font(.body)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                if let email = owner.email {
                    ActionButton(
                        title: "Send Email",
                        icon: "envelope",
                        color: .blue
                    ) {
                        sendEmail(to: email)
                    }
                }
                
                if let phone = owner.phone {
                    ActionButton(
                        title: "Make Call",
                        icon: "phone",
                        color: .green
                    ) {
                        makeCall(to: phone)
                    }
                }
                
                ActionButton(
                    title: "Edit Owner",
                    icon: "pencil",
                    color: .orange
                ) {
                    showingEditOwner = true
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // Helper functions for actions
    private func sendEmail(to email: String) {
        guard let url = URL(string: "mailto:\(email)") else { return }
        UIApplication.shared.open(url)
    }
    
    private func makeCall(to phone: String) {
        guard let url = URL(string: "tel:\(phone)") else { return }
        UIApplication.shared.open(url)
    }
    
    private func removeBusiness(_ business: Business) {
        owner.businesses.removeAll { $0.id == business.id }
        business.owner = nil
    }
}

struct BusinessAssociationRow: View {
    let business: Business
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(business.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(business.industry)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("$\(String(format: "%.0f", business.askingPrice))")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct BusinessSelectorView: View {
    let owner: Owner
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Business.name, order: .forward) private var allBusinesses: [Business]
    
    private var availableBusinesses: [Business] {
        allBusinesses.filter { $0.owner?.id != owner.id }
    }
    
    var body: some View {
        NavigationView {
            List {
                if availableBusinesses.isEmpty {
                    Text("No available businesses to add")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(availableBusinesses) { business in
                        BusinessSelectionRow(business: business) {
                            addBusiness(business)
                        }
                    }
                }
            }
            .navigationTitle("Add Business")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addBusiness(_ business: Business) {
        owner.businesses.append(business)
        business.owner = owner
        dismiss()
    }
}

struct BusinessSelectionRow: View {
    let business: Business
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(business.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(business.industry)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("$\(String(format: "%.0f", business.askingPrice))")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
        }
    }
}

#Preview {
    let owner = Owner(
        name: "John Doe",
        email: "john@example.com",
        phone: "555-123-4567",
        title: "CEO",
        notes: "Very responsive and professional. Interested in selling within 6 months."
    )
    
    return OwnerDetailView(owner: owner)
        .modelContainer(for: Owner.self, inMemory: true)
}
