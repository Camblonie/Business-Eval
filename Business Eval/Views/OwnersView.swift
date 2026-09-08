//
//  OwnersView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData

struct OwnersView: View {
    @Query(sort: \Owner.name, order: .forward) private var owners: [Owner]
    @Query private var allBusinesses: [Business]
    @State private var searchText = ""
    @State private var showingAddOwner = false
    @State private var selectedOwner: Owner?
    @State private var selectedTab: OwnerTab = .owners
    
    // Computes accurate business count for an owner by querying from the Business side
    private func businessCount(for owner: Owner) -> Int {
        allBusinesses.filter { $0.owners.contains(where: { $0.id == owner.id }) }.count
    }
    
    enum OwnerTab: String, CaseIterable {
        case owners = "Owners"
        case analytics = "Analytics"
    }
    
    private var filteredOwners: [Owner] {
        if searchText.isEmpty {
            return owners
        } else {
            return owners.filter { owner in
                owner.name.localizedCaseInsensitiveContains(searchText) ||
                owner.email?.localizedCaseInsensitiveContains(searchText) == true ||
                owner.phone?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                tabSelector
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    // Owners tab
                    ownersTabContent
                        .tag(OwnerTab.owners)
                    
                    // Analytics tab
                    OwnerAnalyticsView()
                        .tag(OwnerTab.analytics)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Owners")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedTab == .owners {
                        Button(action: { showingAddOwner = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddOwner) {
                AddOwnerView()
            }
            .sheet(item: $selectedOwner) { owner in
                NavigationView {
                    OwnerDetailView(owner: owner)
                }
            }
        }
    }
    
    private var tabSelector: some View {
        HStack {
            ForEach(OwnerTab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    Text(tab.rawValue)
                        .font(AppTheme.Fonts.subheadlineMedium)
                        .foregroundColor(selectedTab == tab ? AppTheme.Colors.primary : AppTheme.Colors.secondary)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                .fill(selectedTab == tab ? AppTheme.Colors.primary.opacity(0.1) : Color.clear)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.background)
    }
    
    private var ownersTabContent: some View {
        VStack(spacing: 0) {
            // Search bar (only show on owners tab)
            searchBar
            
            // Content
            if filteredOwners.isEmpty {
                emptyStateView
            } else {
                ownersList
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.Colors.secondary)
            
            TextField("Search owners...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.background)
    }
    
    private var emptyStateView: some View {
        if searchText.isEmpty {
            EmptyStateView(
                icon: "person.2",
                title: "No owners yet",
                message: "Add your first owner to get started",
                actionTitle: "Add Owner"
            ) {
                showingAddOwner = true
            }
        } else {
            EmptyStateView(
                icon: "person.2",
                title: "No owners found",
                message: "Try adjusting your search terms"
            )
        }
    }
    
    private var ownersList: some View {
        List {
            ForEach(Array(filteredOwners.enumerated()), id: \.element.id) { index, owner in
                OwnerRow(owner: owner, businessCount: businessCount(for: owner)) {
                    selectedOwner = owner
                }
                .staggeredAppearance(index: index, speed: .fast)
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct OwnerRow: View {
    let owner: Owner
    let businessCount: Int  // Passed in from parent view for accurate count
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(owner.name)
                        .font(AppTheme.Fonts.headline)
                        .foregroundColor(.primary)
                    
                    if let title = owner.title {
                        Text(title)
                            .font(AppTheme.Fonts.subheadline)
                            .foregroundColor(AppTheme.Colors.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                    Text("\(businessCount)")
                        .font(AppTheme.Fonts.title3)
                        .foregroundColor(AppTheme.Colors.primary)
                    
                    Text("business\(businessCount == 1 ? "" : "es")")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                }
            }
            
            // Contact info row
            HStack {
                if let email = owner.email {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "envelope")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        Text(email)
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                            .lineLimit(1)
                    }
                }
                
                if let phone = owner.phone {
                    Spacer()
                    
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "phone")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        Text(phone)
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                    }
                }
                
                Spacer()
                
                // Contact preference badge
                StatusBadge(owner.contactPreference.rawValue, color: contactPreferenceColor)
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    private var contactPreferenceColor: Color {
        switch owner.contactPreference {
        case .email: return AppTheme.Colors.primary
        case .phone: return AppTheme.Colors.success
        case .text: return AppTheme.Colors.warning
        case .either: return .purple
        }
    }
}

#Preview {
    OwnersView()
        .modelContainer(for: Owner.self, inMemory: true)
}
