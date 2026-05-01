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
    @Query private var businesses: [Business]
    @State private var showingAddBusiness = false
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .nameAZ
    
    enum SortOrder: String, CaseIterable {
        case nameAZ = "A-Z"
        case nameZA = "Z-A"
    }
    
    var filteredBusinesses: [Business] {
        let filtered = if searchText.isEmpty {
            businesses
        } else {
            businesses.filter { business in
                business.name.localizedCaseInsensitiveContains(searchText) ||
                (business.teaser?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                business.industry.localizedCaseInsensitiveContains(searchText) ||
                business.location.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply sorting using displayName for fallback logic
        switch sortOrder {
        case .nameAZ:
            return filtered.sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
        case .nameZA:
            return filtered.sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedDescending }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(filteredBusinesses.enumerated()), id: \.element.id) { index, business in
                    NavigationLink(destination: BusinessDetailView(business: business)) {
                        BusinessRowView(business: business)
                    }
                    .staggeredAppearance(index: index, speed: .fast)
                }
                .onDelete(perform: deleteBusinesses)
            }
            .navigationTitle("Potential Businesses")
            .searchable(text: $searchText, prompt: "Search businesses...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Button(action: { sortOrder = order }) {
                                Label(order.rawValue, systemImage: sortOrder == order ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
                
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
                // Thumbnail image on the left
                if let thumbnailImage = business.thumbnailImage,
                   let uiImage = thumbnailImage.image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(business.primaryExtractedColor, lineWidth: 2)
                        )
                } else {
                    Rectangle()
                        .fill(AppTheme.Colors.secondary.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "building.2.fill")
                                .foregroundColor(AppTheme.Colors.secondary)
                                .font(.title2)
                        )
                }
                
                // Business info in the middle
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(business.displayName)
                        .font(AppTheme.Fonts.headline)
                        .foregroundColor(business.primaryExtractedColor)
                        .italic(business.isUsingTeaser)
                    
                    Text(business.industry)
                        .font(AppTheme.Fonts.subheadline)
                        .foregroundColor(business.secondaryExtractedColor)
                    
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
                        .foregroundColor(business.primaryExtractedColor)
                    
                    BusinessStatusBadge(business.status)
                }
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(business.primaryExtractedColor.opacity(0.05))
        )
        .opacity(business.isOnMarket ? 1.0 : 0.5)
        .saturation(business.isOnMarket ? 1.0 : 0.3)
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
