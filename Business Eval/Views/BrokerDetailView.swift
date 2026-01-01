//
//  BrokerDetailView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/30/25.
//

import SwiftUI
import SwiftData

struct BrokerDetailView: View {
    @Bindable var broker: Broker
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditBroker = false
    @State private var showingBusinessSelector = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sectionSpacing) {
                // Broker Overview
                brokerOverviewSection
                    .fadeIn(delay: 0)
                
                // Contact Information
                contactSection
                    .fadeIn(delay: 0.05)
                
                // Business Information
                businessSection
                    .fadeIn(delay: 0.1)
                
                // Notes
                if let notes = broker.notes, !notes.isEmpty {
                    notesSection
                        .fadeIn(delay: 0.15)
                }
            }
            .padding()
        }
        .navigationTitle(broker.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingEditBroker = true }) {
                        Label("Edit Broker", systemImage: "pencil")
                    }
                    Button(action: { showingBusinessSelector = true }) {
                        Label("Associate Business", systemImage: "building.2")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditBroker) {
            EditBrokerView(broker: broker)
        }
        .sheet(isPresented: $showingBusinessSelector) {
            BrokerBusinessSelectorView(broker: broker)
        }
    }
    
    private var brokerOverviewSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Broker name as hero element
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(broker.name)
                        .font(AppTheme.Fonts.title2)
                        .foregroundColor(.white)
                    
                    if let company = broker.company {
                        Text(company)
                            .font(AppTheme.Fonts.headline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                
                Spacer()
                
                // Business count indicator
                VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                    Text("\(broker.businesses.count)")
                        .font(AppTheme.Fonts.title)
                        .foregroundColor(.white)
                    
                    Text("Business\(broker.businesses.count == 1 ? "" : "es")")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // License and commission badges
            HStack(spacing: AppTheme.Spacing.sm) {
                if let license = broker.license {
                    Label(license, systemImage: "creditcard")
                        .font(AppTheme.Fonts.caption)
                        .padding(.horizontal, AppTheme.Badge.horizontalPadding)
                        .padding(.vertical, AppTheme.Badge.verticalPadding)
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(AppTheme.CornerRadius.medium)
                }
                
                if let commission = broker.commission {
                    Label("\(commission, specifier: "%.1f")%", systemImage: "percent")
                        .font(AppTheme.Fonts.caption)
                        .padding(.horizontal, AppTheme.Badge.horizontalPadding)
                        .padding(.vertical, AppTheme.Badge.verticalPadding)
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(AppTheme.CornerRadius.medium)
                }
            }
        }
        .heroCardStyle()
    }
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Contact Information")
                .font(AppTheme.Fonts.headline)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                if let email = broker.email {
                    ThemedDetailRow(label: "Email", value: email, icon: "envelope")
                    ThemedDivider()
                }
                
                if let phone = broker.phone {
                    ThemedDetailRow(label: "Phone", value: phone, icon: "phone")
                    ThemedDivider()
                }
                
                ThemedDetailRow(label: "Preferred Contact", value: broker.contactPreference.rawValue, icon: "person.crop.circle")
            }
        }
        .cardStyle()
    }
    
    private var businessSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            SectionHeader(
                "Associated Businesses",
                actionTitle: "Add Business"
            ) {
                showingBusinessSelector = true
            }
            
            if broker.businesses.isEmpty {
                Text("No businesses associated")
                    .font(AppTheme.Fonts.subheadline)
                    .foregroundColor(AppTheme.Colors.secondary)
            } else {
                ForEach(broker.businesses.sorted(by: { $0.name < $1.name })) { business in
                    BrokerBusinessRow(business: business)
                }
            }
        }
        .cardStyle()
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Notes")
                .font(AppTheme.Fonts.headline)
            
            Text(broker.notes!)
                .font(AppTheme.Fonts.body)
        }
        .cardStyle()
    }
}

// ContactRow is now replaced by ThemedDetailRow from Theme.swift

struct BrokerBusinessRow: View {
    let business: Business
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(business.name)
                .font(AppTheme.Fonts.subheadlineMedium)
            
            HStack {
                Text(business.industry)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
                
                Spacer()
                
                Text(business.location)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
        }
        .padding(.vertical, AppTheme.Spacing.xs)
    }
}

#Preview {
    let broker = Broker(
        name: "John Smith",
        email: "john@brokerage.com",
        phone: "555-0123",
        company: "ABC Brokerage",
        license: "BRK123456",
        commission: 2.5,
        notes: "Experienced in technology business sales"
    )
    
    return BrokerDetailView(broker: broker)
        .modelContainer(for: Broker.self, inMemory: true)
}
