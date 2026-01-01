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
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sectionSpacing) {
                // Owner Information
                ownerInfoSection
                    .fadeIn(delay: 0)
                
                // Contact Information
                contactSection
                    .fadeIn(delay: 0.05)
                
                // Businesses
                businessesSection
                    .fadeIn(delay: 0.1)
                
                // Notes
                if let notes = owner.notes, !notes.isEmpty {
                    notesSection
                        .fadeIn(delay: 0.15)
                }
                
                // Quick Actions
                quickActionsSection
                    .fadeIn(delay: 0.2)
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
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Owner name as hero element
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(owner.name)
                        .font(AppTheme.Fonts.title2)
                        .foregroundColor(.white)
                    
                    if let title = owner.title {
                        Text(title)
                            .font(AppTheme.Fonts.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                
                Spacer()
                
                // Business count indicator
                VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                    Text("\(owner.businesses.count)")
                        .font(AppTheme.Fonts.title)
                        .foregroundColor(.white)
                    
                    Text("business\(owner.businesses.count == 1 ? "" : "es")")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Contact preference badge
            Text(owner.contactPreference.rawValue)
                .font(AppTheme.Fonts.captionMedium)
                .padding(.horizontal, AppTheme.Badge.horizontalPadding)
                .padding(.vertical, AppTheme.Badge.verticalPadding)
                .background(Color.white.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(AppTheme.CornerRadius.medium)
        }
        .heroCardStyle()
    }
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Contact Information")
                .font(AppTheme.Fonts.headline)
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                if let email = owner.email {
                    ThemedDetailRow(label: "Email", value: email, icon: "envelope")
                    
                    if owner.phone != nil {
                        ThemedDivider()
                    }
                }
                
                if let phone = owner.phone {
                    ThemedDetailRow(label: "Phone", value: phone, icon: "phone")
                }
            }
        }
        .cardStyle()
    }
    
    private var businessesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("Associated Businesses")
                    .font(AppTheme.Fonts.headline)
                
                Spacer()
                
                Button(action: { showingBusinessSelector = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppTheme.Colors.primary)
                        .font(.title2)
                }
            }
            
            if owner.businesses.isEmpty {
                VStack(spacing: AppTheme.Spacing.md) {
                    Text("No businesses associated")
                        .font(AppTheme.Fonts.subheadline)
                        .foregroundColor(AppTheme.Colors.secondary)
                    
                    Button("Add Business") {
                        showingBusinessSelector = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.xl)
            } else {
                VStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(owner.businesses) { business in
                        BusinessAssociationRow(
                            business: business,
                            onRemove: { removeBusiness(business) }
                        )
                    }
                }
            }
        }
        .cardStyle()
        .sheet(isPresented: $showingBusinessSelector) {
            BusinessSelectorView(owner: owner)
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Notes")
                .font(AppTheme.Fonts.headline)
            
            Text(owner.notes!)
                .font(AppTheme.Fonts.body)
        }
        .cardStyle()
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Quick Actions")
                .font(AppTheme.Fonts.headline)
            
            VStack(spacing: AppTheme.Spacing.md) {
                if let email = owner.email {
                    ThemedActionButton(
                        title: "Send Email",
                        icon: "envelope",
                        color: AppTheme.Colors.primary
                    ) {
                        sendEmail(to: email)
                    }
                }
                
                if let phone = owner.phone {
                    ThemedActionButton(
                        title: "Make Call",
                        icon: "phone",
                        color: AppTheme.Colors.success
                    ) {
                        makeCall(to: phone)
                    }
                }
                
                ThemedActionButton(
                    title: "Edit Owner",
                    icon: "pencil",
                    color: AppTheme.Colors.warning
                ) {
                    showingEditOwner = true
                }
            }
        }
        .cardStyle()
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
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(business.name)
                    .font(AppTheme.Fonts.subheadlineMedium)
                
                Text(business.industry)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
                
                Text(formatAskingPrice(business.askingPrice))
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.money)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(AppTheme.Colors.destructive)
                    .font(.title3)
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .padding(.horizontal, AppTheme.Spacing.md)
        .background(AppTheme.Colors.background)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    private func formatAskingPrice(_ price: Double) -> String {
        if price >= 1_000_000 {
            return String(format: "$%.1fM", price / 1_000_000)
        } else if price >= 1_000 {
            return String(format: "$%.0fK", price / 1_000)
        } else {
            return String(format: "$%.0f", price)
        }
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
                        .foregroundColor(AppTheme.Colors.secondary)
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
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(business.name)
                        .font(AppTheme.Fonts.subheadlineMedium)
                    
                    Text(business.industry)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                    
                    Text(formatAskingPrice(business.askingPrice))
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.money)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle")
                    .foregroundColor(AppTheme.Colors.primary)
                    .font(.title3)
            }
            .padding(.vertical, AppTheme.Spacing.xs)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatAskingPrice(_ price: Double) -> String {
        if price >= 1_000_000 {
            return String(format: "$%.1fM", price / 1_000_000)
        } else if price >= 1_000 {
            return String(format: "$%.0fK", price / 1_000)
        } else {
            return String(format: "$%.0f", price)
        }
    }
}

// ActionButton is now replaced by ThemedActionButton from Theme.swift

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
