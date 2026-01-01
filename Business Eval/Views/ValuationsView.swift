//
//  ValuationsView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData

struct ValuationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Valuation.createdAt, order: .reverse) private var valuations: [Valuation]
    @Query(sort: \Business.name, order: .forward) private var businesses: [Business]
    @State private var searchText = ""
    @State private var selectedMethodology: ValuationMethodology? = nil
    @State private var selectedConfidence: ConfidenceLevel? = nil
    @State private var sortOption: SortOption = .dateDescending
    @State private var showingAnalytics = false
    @State private var showingQuickValuation = false
    @State private var selectedViewMode: ViewMode = .all
    
    enum ViewMode: String, CaseIterable {
        case all = "All Valuations"
        case byBusiness = "By Business"
        case needsValuation = "Needs Valuation"
    }
    
    // Businesses that have no valuations
    private var businessesNeedingValuation: [Business] {
        businesses.filter { $0.valuations.isEmpty }
    }
    
    // Businesses grouped with their valuations
    private var businessesWithValuations: [Business] {
        businesses.filter { !$0.valuations.isEmpty }
    }
    
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
                // View Mode Selector
                Picker("View Mode", selection: $selectedViewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, AppTheme.Spacing.md)
                
                // Content based on view mode
                switch selectedViewMode {
                case .all:
                    allValuationsView
                case .byBusiness:
                    byBusinessView
                case .needsValuation:
                    needsValuationView
                }
            }
            .navigationTitle("Valuations")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingQuickValuation = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAnalytics = true }) {
                        Image(systemName: "chart.bar.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAnalytics) {
                ValuationAnalyticsView()
            }
            .sheet(isPresented: $showingQuickValuation) {
                QuickValuationView()
            }
        }
    }
    
    // MARK: - All Valuations View
    private var allValuationsView: some View {
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
            if filteredAndSortedValuations.isEmpty {
                EmptyStateView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "No Valuations",
                    message: "Create your first valuation to get started",
                    actionTitle: "Quick Valuation"
                ) {
                    showingQuickValuation = true
                }
            } else {
                List {
                    ForEach(Array(filteredAndSortedValuations.enumerated()), id: \.element.id) { index, valuation in
                        NavigationLink(destination: ValuationDetailView(valuation: valuation)) {
                            ValuationRowView(valuation: valuation)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteValuation(valuation)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .staggeredAppearance(index: index)
                    }
                }
            }
        }
    }
    
    // MARK: - By Business View
    private var byBusinessView: some View {
        List {
            ForEach(businessesWithValuations) { business in
                Section {
                    ForEach(business.valuations.sorted(by: { $0.createdAt > $1.createdAt })) { valuation in
                        NavigationLink(destination: ValuationDetailView(valuation: valuation)) {
                            ValuationRowView(valuation: valuation, showBusinessName: false)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteValuation(valuation)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    BusinessValuationHeader(business: business)
                }
            }
            
            if businessesWithValuations.isEmpty {
                Section {
                    EmptyStateView(
                        icon: "building.2",
                        title: "No Valuations Yet",
                        message: "Calculate valuations for your businesses",
                        actionTitle: "Quick Valuation"
                    ) {
                        showingQuickValuation = true
                    }
                }
            }
        }
    }
    
    // MARK: - Needs Valuation View
    private var needsValuationView: some View {
        List {
            if businessesNeedingValuation.isEmpty {
                Section {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.success)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("All Caught Up!")
                                .font(AppTheme.Fonts.headline)
                            Text("Every business has at least one valuation")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                        }
                    }
                    .padding(.vertical, AppTheme.Spacing.md)
                }
            } else {
                Section {
                    Text("\(businessesNeedingValuation.count) business\(businessesNeedingValuation.count == 1 ? "" : "es") need\(businessesNeedingValuation.count == 1 ? "s" : "") valuation")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                }
                
                ForEach(businessesNeedingValuation) { business in
                    BusinessNeedsValuationRow(business: business) {
                        showingQuickValuation = true
                    }
                }
            }
        }
    }
    
    // MARK: - Delete Valuation
    private func deleteValuation(_ valuation: Valuation) {
        withAnimation {
            // Remove from business relationship if exists
            if let business = valuation.business {
                business.valuations.removeAll { $0.id == valuation.id }
            }
            modelContext.delete(valuation)
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

// MARK: - Business Valuation Header
/// Header for business section in By Business view
struct BusinessValuationHeader: View {
    let business: Business
    
    private var latestValuation: Valuation? {
        business.valuations.sorted(by: { $0.createdAt > $1.createdAt }).first
    }
    
    private var averageValue: Double {
        guard !business.valuations.isEmpty else { return 0 }
        return business.valuations.reduce(0) { $0 + $1.calculatedValue } / Double(business.valuations.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack {
                Text(business.name)
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(business.valuations.count) valuation\(business.valuations.count == 1 ? "" : "s")")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
            
            HStack {
                Text("Avg: \(formatCurrency(averageValue))")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.money)
                
                Text("•")
                    .foregroundColor(AppTheme.Colors.secondary)
                
                Text("Asking: \(formatCurrency(business.askingPrice))")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
        }
        .textCase(nil)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        if amount >= 1_000_000 {
            return String(format: "$%.1fM", amount / 1_000_000)
        } else if amount >= 1_000 {
            return String(format: "$%.0fK", amount / 1_000)
        } else {
            return String(format: "$%.0f", amount)
        }
    }
}

// MARK: - Business Needs Valuation Row
/// Row for businesses that need valuation
struct BusinessNeedsValuationRow: View {
    let business: Business
    let onCalculate: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(business.name)
                    .font(AppTheme.Fonts.subheadlineMedium)
                
                HStack {
                    Text(business.industry)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                    
                    Text("•")
                        .foregroundColor(AppTheme.Colors.secondary)
                    
                    Text(formatCurrency(business.askingPrice))
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.money)
                }
                
                // Quick metrics for valuation context
                HStack {
                    Label("Rev: \(formatCurrency(business.annualRevenue))", systemImage: "chart.line.uptrend.xyaxis")
                    Label("Profit: \(formatCurrency(business.annualProfit))", systemImage: "dollarsign.circle")
                }
                .font(.caption2)
                .foregroundColor(AppTheme.Colors.secondary)
            }
            
            Spacer()
            
            Button(action: onCalculate) {
                Image(systemName: "calculator")
                    .font(.system(size: AppTheme.IconSize.medium))
                    .foregroundColor(AppTheme.Colors.primary)
            }
        }
        .padding(.vertical, AppTheme.Spacing.xs)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        if amount >= 1_000_000 {
            return String(format: "$%.1fM", amount / 1_000_000)
        } else if amount >= 1_000 {
            return String(format: "$%.0fK", amount / 1_000)
        } else {
            return String(format: "$%.0f", amount)
        }
    }
}

// MARK: - Valuation Row View
/// Row for displaying a single valuation
struct ValuationRowView: View {
    let valuation: Valuation
    var showBusinessName: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack {
                if showBusinessName, let businessName = valuation.business?.name {
                    Text(businessName)
                        .font(AppTheme.Fonts.subheadlineMedium)
                }
                
                Spacer()
                
                Text(formatCurrency(valuation.calculatedValue))
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(AppTheme.Colors.money)
            }
            
            HStack {
                Text(valuation.methodology.rawValue)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
                
                Spacer()
                
                StatusBadge(valuation.confidenceLevel.rawValue, color: confidenceColor)
            }
            
            HStack {
                Text("\(valuation.multiple, specifier: "%.2f")x multiple")
                    .font(.caption2)
                    .foregroundColor(AppTheme.Colors.secondary)
                
                Spacer()
                
                Text(valuation.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
        }
        .padding(.vertical, AppTheme.Spacing.xs)
    }
    
    private var confidenceColor: Color {
        switch valuation.confidenceLevel {
        case .low: return AppTheme.Colors.destructive
        case .medium: return AppTheme.Colors.warning
        case .high: return AppTheme.Colors.success
        case .veryHigh: return AppTheme.Colors.primary
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        if amount >= 1_000_000 {
            return String(format: "$%.2fM", amount / 1_000_000)
        } else if amount >= 1_000 {
            return String(format: "$%.0fK", amount / 1_000)
        } else {
            return String(format: "$%.0f", amount)
        }
    }
}

#Preview {
    ValuationsView()
        .modelContainer(for: [Valuation.self, Business.self], inMemory: true)
}
