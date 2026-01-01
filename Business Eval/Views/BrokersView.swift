//
//  BrokersView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/30/25.
//

import SwiftUI
import SwiftData

struct BrokersView: View {
    @Query(sort: \Broker.name, order: .forward) private var brokers: [Broker]
    @State private var searchText = ""
    @State private var showingAddBroker = false
    @State private var selectedBroker: Broker?
    @State private var selectedTab: BrokerTab = .brokers
    
    enum BrokerTab: String, CaseIterable {
        case brokers = "Brokers"
        case analytics = "Analytics"
    }
    
    private var filteredBrokers: [Broker] {
        if searchText.isEmpty {
            return brokers
        } else {
            return brokers.filter { broker in
                broker.name.localizedCaseInsensitiveContains(searchText) ||
                broker.email?.localizedCaseInsensitiveContains(searchText) == true ||
                broker.phone?.localizedCaseInsensitiveContains(searchText) == true ||
                broker.company?.localizedCaseInsensitiveContains(searchText) == true
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
                    // Brokers tab
                    brokersTabContent
                        .tag(BrokerTab.brokers)
                    
                    // Analytics tab
                    BrokerAnalyticsView()
                        .tag(BrokerTab.analytics)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Brokers")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedTab == .brokers {
                        Button(action: { showingAddBroker = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddBroker) {
                AddBrokerView()
            }
            .sheet(item: $selectedBroker) { broker in
                NavigationView {
                    BrokerDetailView(broker: broker)
                }
            }
        }
    }
    
    private var tabSelector: some View {
        HStack {
            ForEach(BrokerTab.allCases, id: \.self) { tab in
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
    
    private var brokersTabContent: some View {
        VStack(spacing: 0) {
            // Search bar (only show on brokers tab)
            searchBar
            
            // Content
            if filteredBrokers.isEmpty {
                emptyStateView
            } else {
                brokersList
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.Colors.secondary)
            
            TextField("Search brokers...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.background)
    }
    
    private var emptyStateView: some View {
        if searchText.isEmpty {
            EmptyStateView(
                icon: "briefcase",
                title: "No brokers yet",
                message: "Add your first broker to get started",
                actionTitle: "Add Broker"
            ) {
                showingAddBroker = true
            }
        } else {
            EmptyStateView(
                icon: "briefcase",
                title: "No brokers found",
                message: "Try adjusting your search terms"
            )
        }
    }
    
    private var brokersList: some View {
        List {
            ForEach(Array(filteredBrokers.enumerated()), id: \.element.id) { index, broker in
                BrokerRow(broker: broker) {
                    selectedBroker = broker
                }
                .staggeredAppearance(index: index)
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct BrokerRow: View {
    let broker: Broker
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(broker.name)
                        .font(AppTheme.Fonts.headline)
                        .foregroundColor(.primary)
                    
                    if let company = broker.company {
                        Text(company)
                            .font(AppTheme.Fonts.subheadline)
                            .foregroundColor(AppTheme.Colors.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                    Text("\(broker.businesses.count)")
                        .font(AppTheme.Fonts.title3)
                        .foregroundColor(AppTheme.Colors.primary)
                    
                    Text("business\(broker.businesses.count == 1 ? "" : "es")")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                }
            }
            
            // Contact info row
            HStack {
                if let email = broker.email {
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
                
                if let phone = broker.phone {
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
                StatusBadge(broker.contactPreference.rawValue, color: contactPreferenceColor)
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
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

#Preview {
    BrokersView()
        .modelContainer(for: Broker.self, inMemory: true)
}
