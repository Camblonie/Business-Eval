//
//  ValuationsView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData

struct ValuationsView: View {
    @Query(sort: \Valuation.createdAt, order: .reverse) private var valuations: [Valuation]
    @State private var searchText = ""
    @State private var selectedMethodology: ValuationMethodology? = nil
    @State private var selectedConfidence: ConfidenceLevel? = nil
    @State private var sortOption: SortOption = .dateDescending
    @State private var showingAnalytics = false
    
    enum SortOption: String, CaseIterable {
        case dateDescending = "Date (Newest)"
        case dateAscending = "Date (Oldest)"
        case valueDescending = "Value (High to Low)"
        case valueAscending = "Value (Low to High)"
        case confidenceLevel = "Confidence Level"
        case methodology = "Methodology"
    }
    
    var filteredAndSortedValuations: [Valuation] {
        var filtered = valuations
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { valuation in
                (valuation.business?.name.localizedCaseInsensitiveContains(searchText) ?? false) ||
                valuation.methodology.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by methodology
        if let methodology = selectedMethodology {
            filtered = filtered.filter { $0.methodology == methodology }
        }
        
        // Filter by confidence level
        if let confidence = selectedConfidence {
            filtered = filtered.filter { $0.confidenceLevel == confidence }
        }
        
        // Sort
        switch sortOption {
        case .dateDescending:
            return filtered.sorted { $0.createdAt > $1.createdAt }
        case .dateAscending:
            return filtered.sorted { $0.createdAt < $1.createdAt }
        case .valueDescending:
            return filtered.sorted { $0.calculatedValue > $1.calculatedValue }
        case .valueAscending:
            return filtered.sorted { $0.calculatedValue < $1.calculatedValue }
        case .confidenceLevel:
            return filtered.sorted { confidenceOrder($0.confidenceLevel) > confidenceOrder($1.confidenceLevel) }
        case .methodology:
            return filtered.sorted { $0.methodology.rawValue < $1.methodology.rawValue }
        }
    }
    
    private func confidenceOrder(_ level: ConfidenceLevel) -> Int {
        switch level {
        case .veryHigh: return 4
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filters
                VStack(spacing: AppTheme.Spacing.md) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppTheme.Colors.secondary)
                        TextField("Search valuations...", text: $searchText)
                    }
                    .searchBarStyle()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppTheme.Spacing.md) {
                            // Methodology Filter
                            Menu {
                                Button("All Methodologies") {
                                    selectedMethodology = nil
                                }
                                ForEach(ValuationMethodology.allCases, id: \.self) { methodology in
                                    Button(methodology.rawValue) {
                                        selectedMethodology = methodology
                                    }
                                }
                            } label: {
                                ValuationFilterChip(
                                    title: selectedMethodology?.rawValue ?? "Methodology",
                                    isSelected: selectedMethodology != nil
                                )
                            }
                            
                            // Confidence Filter
                            Menu {
                                Button("All Levels") {
                                    selectedConfidence = nil
                                }
                                ForEach(ConfidenceLevel.allCases, id: \.self) { confidence in
                                    Button(confidence.rawValue) {
                                        selectedConfidence = confidence
                                    }
                                }
                            } label: {
                                ValuationFilterChip(
                                    title: selectedConfidence?.rawValue ?? "Confidence",
                                    isSelected: selectedConfidence != nil
                                )
                            }
                            
                            // Sort Menu
                            Menu {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Button(option.rawValue) {
                                        sortOption = option
                                    }
                                }
                            } label: {
                                ValuationFilterChip(
                                    title: sortOption.rawValue,
                                    isSelected: true
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(AppTheme.Colors.background)
                
                // Valuations List
                List {
                    ForEach(Array(filteredAndSortedValuations.enumerated()), id: \.element.id) { index, valuation in
                        NavigationLink(destination: ValuationDetailView(valuation: valuation)) {
                            ValuationRowView(valuation: valuation)
                        }
                        .staggeredAppearance(index: index)
                    }
                }
            }
        .navigationTitle("Valuations")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAnalytics = true }) {
                    Image(systemName: "chart.bar.fill")
                }
            }
        }
        .sheet(isPresented: $showingAnalytics) {
            ValuationAnalyticsView()
        }
        }
    }
    
}

struct ValuationFilterChip: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(AppTheme.Fonts.caption)
            .padding(.horizontal, AppTheme.Badge.largeHorizontalPadding)
            .padding(.vertical, AppTheme.Badge.largeVerticalPadding)
            .background(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.cardBackground)
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(AppTheme.CornerRadius.pill)
    }
}

#Preview {
    ValuationsView()
        .modelContainer(for: Valuation.self, inMemory: true)
}
