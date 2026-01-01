//
//  BusinessCorrespondenceSelectorView.swift
//  Business Eval
//
//  Created by Scott Campbell on 1/1/26.
//
//  Allows linking existing unlinked correspondence to a business.
//

import SwiftUI
import SwiftData

struct BusinessCorrespondenceSelectorView: View {
    let business: Business
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Correspondence.date, order: .reverse) private var allCorrespondence: [Correspondence]
    @State private var searchText = ""
    
    // Filter to show only unlinked correspondence or correspondence linked to other businesses
    private var availableCorrespondence: [Correspondence] {
        let filtered = allCorrespondence.filter { correspondence in
            // Show unlinked correspondence
            correspondence.business == nil
        }
        
        if searchText.isEmpty {
            return filtered
        }
        
        return filtered.filter { correspondence in
            correspondence.subject.localizedCaseInsensitiveContains(searchText) ||
            correspondence.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppTheme.Colors.secondary)
                    
                    TextField("Search correspondence...", text: $searchText)
                        .textInputAutocapitalization(.never)
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)
                .padding()
                
                // Content
                if availableCorrespondence.isEmpty {
                    emptyStateView
                } else {
                    correspondenceList
                }
            }
            .navigationTitle("Link Correspondence")
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
    
    private var emptyStateView: some View {
        EmptyStateView(
            icon: "envelope",
            title: "No unlinked correspondence",
            message: searchText.isEmpty 
                ? "All correspondence is already linked to businesses" 
                : "Try a different search term"
        )
    }
    
    private var correspondenceList: some View {
        List {
            ForEach(availableCorrespondence) { correspondence in
                CorrespondenceLinkRow(correspondence: correspondence) {
                    linkCorrespondence(correspondence)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // Links the correspondence to this business
    private func linkCorrespondence(_ correspondence: Correspondence) {
        correspondence.business = business
        business.correspondence.append(correspondence)
        dismiss()
    }
}

// MARK: - Correspondence Link Row
struct CorrespondenceLinkRow: View {
    let correspondence: Correspondence
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                // Type icon
                Image(systemName: typeIcon)
                    .font(.system(size: AppTheme.IconSize.medium))
                    .foregroundColor(typeColor)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(correspondence.subject)
                        .font(AppTheme.Fonts.subheadlineMedium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(correspondence.content)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(correspondence.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2)
                            .foregroundColor(AppTheme.Colors.secondary)
                        
                        Spacer()
                        
                        StatusBadge(correspondence.type.rawValue, color: typeColor)
                        
                        StatusBadge(
                            correspondence.direction.rawValue,
                            color: correspondence.direction == .inbound ? AppTheme.Colors.inbound : AppTheme.Colors.outbound
                        )
                    }
                }
                
                Spacer()
                
                Image(systemName: "link")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.primary)
            }
            .padding(.vertical, AppTheme.Spacing.sm)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var typeIcon: String {
        switch correspondence.type {
        case .email: return "envelope.fill"
        case .phoneCall: return "phone.fill"
        case .textMessage: return "message.fill"
        case .meeting: return "person.2.fill"
        case .letter: return "doc.text.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    private var typeColor: Color {
        switch correspondence.type {
        case .email: return AppTheme.Colors.primary
        case .phoneCall: return AppTheme.Colors.success
        case .textMessage: return .purple
        case .meeting: return AppTheme.Colors.warning
        case .letter: return .gray
        case .other: return AppTheme.Colors.destructive
        }
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
    
    return BusinessCorrespondenceSelectorView(business: business)
        .modelContainer(for: [Correspondence.self, Business.self], inMemory: true)
}
