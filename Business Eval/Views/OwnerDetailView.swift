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
            }
            .padding()
        }
        .navigationTitle(owner.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
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
            Text("Associated Businesses")
                .font(.headline)
                .fontWeight(.bold)
            
            if owner.businesses.isEmpty {
                Text("No businesses associated")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(owner.businesses) { business in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(business.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(business.industry)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("$\(business.askingPrice, specifier: "%.0f")")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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
