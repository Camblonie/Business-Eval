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
    @State private var searchText = ""
    @State private var showingAddOwner = false
    @State private var selectedOwner: Owner?
    @State private var selectedTab: OwnerTab = .owners
    
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
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedTab == tab ? .blue : .secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedTab == tab ? Color.blue.opacity(0.1) : Color.clear)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
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
                .foregroundColor(.secondary)
            
            TextField("Search owners...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            if searchText.isEmpty {
                Text("No owners yet")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Add your first owner to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Add Owner") {
                    showingAddOwner = true
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("No owners found")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Try adjusting your search terms")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var ownersList: some View {
        List {
            ForEach(filteredOwners) { owner in
                OwnerRow(owner: owner) {
                    selectedOwner = owner
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct OwnerRow: View {
    let owner: Owner
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(owner.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let title = owner.title {
                        Text(title)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(owner.businesses.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("business\(owner.businesses.count == 1 ? "" : "es")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Contact info row
            HStack {
                if let email = owner.email {
                    HStack(spacing: 4) {
                        Image(systemName: "envelope")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                if let phone = owner.phone {
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "phone")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(phone)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Contact preference badge
                Text(owner.contactPreference.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(contactPreferenceColor.opacity(0.2))
                    .foregroundColor(contactPreferenceColor)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
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

#Preview {
    OwnersView()
        .modelContainer(for: Owner.self, inMemory: true)
}
