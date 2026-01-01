//
//  BusinessListView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData

struct BusinessListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Business.createdAt, order: .reverse) private var businesses: [Business]
    @State private var showingAddBusiness = false
    @State private var searchText = ""
    
    var filteredBusinesses: [Business] {
        if searchText.isEmpty {
            return businesses
        } else {
            return businesses.filter { business in
                business.name.localizedCaseInsensitiveContains(searchText) ||
                business.industry.localizedCaseInsensitiveContains(searchText) ||
                business.location.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(filteredBusinesses.enumerated()), id: \.element.id) { index, business in
                    NavigationLink(destination: BusinessDetailView(business: business)) {
                        BusinessRowView(business: business)
                    }
                    .staggeredAppearance(index: index)
                }
                .onDelete(perform: deleteBusinesses)
            }
            .navigationTitle("Potential Businesses")
            .searchable(text: $searchText, prompt: "Search businesses...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddBusiness = true }) {
                        Label("Add Business", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBusiness) {
                AddBusinessView()
            }
        }
    }
    
    private func deleteBusinesses(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredBusinesses[index])
            }
        }
    }
}

struct BusinessRowView: View {
    let business: Business
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(alignment: .top) {
                // Left side: Business info
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(business.name)
                        .font(AppTheme.Fonts.headline)
                        .foregroundColor(.primary)
                    
                    Text(business.industry)
                        .font(AppTheme.Fonts.subheadline)
                        .foregroundColor(AppTheme.Colors.secondary)
                    
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Label(business.location, systemImage: "location.fill")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                    }
                }
                
                Spacer()
                
                // Right side: Price and status with visual hierarchy
                VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                    Text(formatAskingPrice(business.askingPrice))
                        .font(AppTheme.Fonts.subheadlineMedium)
                        .foregroundColor(AppTheme.Colors.money)
                    
                    BusinessStatusBadge(business.status)
                }
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
    }
    
    /// Formats the asking price with K/M suffix for readability
    private func formatAskingPrice(_ price: Double) -> String {
        if price >= 1_000_000 {
            return String(format: "Asking: $%.1fM", price / 1_000_000)
        } else if price >= 1_000 {
            return String(format: "Asking: $%.0fK", price / 1_000)
        } else {
            return String(format: "Asking: $%.0f", price)
        }
    }
}

#Preview {
    BusinessListView()
        .modelContainer(for: Business.self, inMemory: true)
}
