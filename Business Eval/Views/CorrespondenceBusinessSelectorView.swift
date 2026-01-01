//
//  CorrespondenceBusinessSelectorView.swift
//  Business Eval
//
//  Created by Scott Campbell on 1/1/26.
//
//  Allows linking a correspondence item to a business.
//

import SwiftUI
import SwiftData

struct CorrespondenceBusinessSelectorView: View {
    @Bindable var correspondence: Correspondence
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Business.name, order: .forward) private var businesses: [Business]
    @State private var searchText = ""
    
    // Filter businesses based on search text
    private var filteredBusinesses: [Business] {
        if searchText.isEmpty {
            return businesses
        }
        return businesses.filter { business in
            business.name.localizedCaseInsensitiveContains(searchText) ||
            business.industry.localizedCaseInsensitiveContains(searchText) ||
            business.location.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppTheme.Colors.secondary)
                    
                    TextField("Search businesses...", text: $searchText)
                        .textInputAutocapitalization(.never)
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)
                .padding()
                
                // Current link status
                if let currentBusiness = correspondence.business {
                    currentLinkSection(currentBusiness)
                }
                
                // Business list
                if filteredBusinesses.isEmpty {
                    emptyStateView
                } else {
                    businessesList
                }
            }
            .navigationTitle("Link to Business")
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
    
    // Shows the currently linked business with option to unlink
    private func currentLinkSection(_ business: Business) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Currently Linked")
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.secondary)
            
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(business.name)
                        .font(AppTheme.Fonts.subheadlineMedium)
                    
                    Text(business.industry)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                }
                
                Spacer()
                
                Button(action: { unlinkBusiness() }) {
                    Text("Unlink")
                        .font(AppTheme.Fonts.captionMedium)
                        .foregroundColor(AppTheme.Colors.destructive)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(AppTheme.Colors.destructive.opacity(0.1))
                        .cornerRadius(AppTheme.CornerRadius.medium)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.success.opacity(0.1))
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
        .padding(.horizontal)
        .padding(.bottom, AppTheme.Spacing.sm)
    }
    
    private var emptyStateView: some View {
        EmptyStateView(
            icon: "building.2",
            title: "No businesses found",
            message: searchText.isEmpty ? "Add a business first to link correspondence" : "Try a different search term"
        )
    }
    
    private var businessesList: some View {
        List {
            ForEach(filteredBusinesses) { business in
                BusinessLinkRow(
                    business: business,
                    isCurrentlyLinked: business.id == correspondence.business?.id
                ) {
                    linkToBusiness(business)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // Links the correspondence to the selected business
    private func linkToBusiness(_ business: Business) {
        // Remove from current business if exists
        if let currentBusiness = correspondence.business {
            currentBusiness.correspondence.removeAll { $0.id == correspondence.id }
        }
        
        // Link to new business
        correspondence.business = business
        business.correspondence.append(correspondence)
        
        dismiss()
    }
    
    // Unlinks the correspondence from the current business
    private func unlinkBusiness() {
        if let currentBusiness = correspondence.business {
            currentBusiness.correspondence.removeAll { $0.id == correspondence.id }
        }
        correspondence.business = nil
        dismiss()
    }
}

// MARK: - Business Link Row
struct BusinessLinkRow: View {
    let business: Business
    let isCurrentlyLinked: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    HStack {
                        Text(business.name)
                            .font(AppTheme.Fonts.subheadlineMedium)
                            .foregroundColor(.primary)
                        
                        if isCurrentlyLinked {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.Colors.success)
                                .font(.caption)
                        }
                    }
                    
                    Text(business.industry)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                    
                    HStack {
                        Text(business.location)
                            .font(.caption2)
                            .foregroundColor(AppTheme.Colors.secondary)
                        
                        Spacer()
                        
                        StatusBadge(business.status.rawValue, color: AppTheme.Colors.statusColor(for: business.status))
                    }
                }
                
                Spacer()
                
                if !isCurrentlyLinked {
                    Image(systemName: "link")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            .padding(.vertical, AppTheme.Spacing.sm)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isCurrentlyLinked)
        .opacity(isCurrentlyLinked ? 0.6 : 1.0)
    }
}

#Preview {
    let correspondence = Correspondence(
        subject: "Test Correspondence",
        content: "This is a test.",
        type: .email,
        direction: .outbound
    )
    
    return CorrespondenceBusinessSelectorView(correspondence: correspondence)
        .modelContainer(for: [Correspondence.self, Business.self], inMemory: true)
}
