//
//  CorrespondenceView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData

struct CorrespondenceView: View {
    @Query(sort: \Correspondence.date, order: .reverse) private var correspondence: [Correspondence]
    @Query(sort: \Business.name, order: .forward) private var businesses: [Business]
    
    @State private var searchText = ""
    @State private var selectedFilter: CorrespondenceFilter = .all
    @State private var selectedBusiness: Business? = nil
    @State private var showingAddCorrespondence = false
    @State private var selectedCorrespondence: Correspondence?
    @State private var selectedViewType: ViewType = .timeline
    
    enum CorrespondenceFilter: String, CaseIterable {
        case all = "All"
        case emails = "Emails"
        case calls = "Calls"
        case meetings = "Meetings"
        case texts = "Texts"
        case letters = "Letters"
        case other = "Other"
    }
    
    enum ViewType: String, CaseIterable {
        case timeline = "Timeline"
        case list = "List"
        case analytics = "Analytics"
    }
    
    private var filteredCorrespondence: [Correspondence] {
        var filtered = correspondence
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { item in
                item.subject.localizedCaseInsensitiveContains(searchText) ||
                item.content.localizedCaseInsensitiveContains(searchText) ||
                item.business?.name.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // Apply type filter
        switch selectedFilter {
        case .all:
            break
        case .emails:
            filtered = filtered.filter { $0.type == .email }
        case .calls:
            filtered = filtered.filter { $0.type == .phoneCall }
        case .meetings:
            filtered = filtered.filter { $0.type == .meeting }
        case .texts:
            filtered = filtered.filter { $0.type == .textMessage }
        case .letters:
            filtered = filtered.filter { $0.type == .letter }
        case .other:
            filtered = filtered.filter { $0.type == .other }
        }
        
        // Apply business filter
        if let business = selectedBusiness {
            filtered = filtered.filter { $0.business?.id == business.id }
        }
        
        return filtered
    }
    
    private var groupedCorrespondence: [String: [Correspondence]] {
        Dictionary(grouping: filteredCorrespondence) { item in
            let calendar = Calendar.current
            if calendar.isDateInToday(item.date) {
                return "Today"
            } else if calendar.isDateInYesterday(item.date) {
                return "Yesterday"
            } else if calendar.isDate(item.date, equalTo: Date(), toGranularity: .weekOfYear) {
                return "This Week"
            } else if calendar.isDate(item.date, equalTo: Date(), toGranularity: .month) {
                return "This Month"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                return formatter.string(from: item.date)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // View type selector
                viewTypeSelector
                
                // Content based on selected view
                TabView(selection: $selectedViewType) {
                    // Timeline view
                    timelineViewContent
                        .tag(ViewType.timeline)
                    
                    // List view
                    listViewContent
                        .tag(ViewType.list)
                    
                    // Analytics view
                    CorrespondenceAnalyticsView()
                        .tag(ViewType.analytics)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Correspondence")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingAddCorrespondence = true }) {
                            Label("Add Correspondence", systemImage: "plus")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddCorrespondence) {
                AddCorrespondenceView(business: nil)
            }
            .sheet(item: $selectedCorrespondence) { item in
                CorrespondenceDetailView(correspondence: item)
            }
        }
    }
    
    private var viewTypeSelector: some View {
        HStack {
            ForEach(ViewType.allCases, id: \.self) { type in
                Button(action: { selectedViewType = type }) {
                    Text(type.rawValue)
                        .font(AppTheme.Fonts.subheadlineMedium)
                        .foregroundColor(selectedViewType == type ? AppTheme.Colors.primary : AppTheme.Colors.secondary)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                .fill(selectedViewType == type ? AppTheme.Colors.primary.opacity(0.1) : Color.clear)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.background)
    }
    
    private var timelineViewContent: some View {
        VStack(spacing: 0) {
            // Search and filters
            searchAndFilterSection
            
            // Timeline content
            if filteredCorrespondence.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(groupedCorrespondence.keys.sorted(by: dateSortOrder), id: \.self) { groupName in
                            if let items = groupedCorrespondence[groupName], !items.isEmpty {
                                CorrespondenceSection(title: groupName, items: items) { item in
                                    selectedCorrespondence = item
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private var listViewContent: some View {
        VStack(spacing: 0) {
            // Search and filters
            searchAndFilterSection
            
            // List content
            if filteredCorrespondence.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(filteredCorrespondence) { item in
                        CorrespondenceRow(correspondence: item) {
                            selectedCorrespondence = item
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    private var searchAndFilterSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.Colors.secondary)
                
                TextField("Search correspondence...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    // Type filter
                    Menu {
                        ForEach(CorrespondenceFilter.allCases, id: \.self) { filter in
                            Button(filter.rawValue) {
                                selectedFilter = filter
                            }
                        }
                    } label: {
                        CorrespondenceFilterChip(title: selectedFilter.rawValue, isSelected: true)
                    }
                    
                    // Business filter
                    Menu {
                        Button("All Businesses") {
                            selectedBusiness = nil
                        }
                        
                        ForEach(businesses, id: \.id) { business in
                            Button(business.name) {
                                selectedBusiness = business
                            }
                        }
                    } label: {
                        CorrespondenceFilterChip(
                            title: selectedBusiness?.name ?? "All Businesses",
                            isSelected: selectedBusiness == nil
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.background)
    }
    
    private var emptyStateView: some View {
        if searchText.isEmpty && selectedFilter == .all && selectedBusiness == nil {
            EmptyStateView(
                icon: "envelope",
                title: "No correspondence yet",
                message: "Add your first correspondence to get started",
                actionTitle: "Add Correspondence"
            ) {
                showingAddCorrespondence = true
            }
        } else {
            EmptyStateView(
                icon: "envelope",
                title: "No correspondence found",
                message: "Try adjusting your search or filters"
            )
        }
    }
    
    private func dateSortOrder(_ date1: String, _ date2: String) -> Bool {
        let order = ["Today", "Yesterday", "This Week", "This Month"]
        
        if order.contains(date1) && order.contains(date2) {
            return order.firstIndex(of: date1)! < order.firstIndex(of: date2)!
        } else if order.contains(date1) {
            return true
        } else if order.contains(date2) {
            return false
        } else {
            // For month names, sort by date
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            
            if let d1 = formatter.date(from: date1), let d2 = formatter.date(from: date2) {
                return d1 > d2
            }
            
            return date1 > date2
        }
    }
}

struct CorrespondenceSection: View {
    let title: String
    let items: [Correspondence]
    let onTap: (Correspondence) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Section header
            Text(title)
                .font(AppTheme.Fonts.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            // Timeline items with staggered animation
            VStack(spacing: AppTheme.Spacing.md) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    CorrespondenceTimelineItem(correspondence: item) {
                        onTap(item)
                    }
                    .staggeredAppearance(index: index)
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, AppTheme.Spacing.xl)
    }
}

struct CorrespondenceTimelineItem: View {
    let correspondence: Correspondence
    let onTap: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
            // Timeline indicator
            VStack(spacing: 0) {
                Circle()
                    .fill(typeColor)
                    .frame(width: 12, height: 12)
                
                Rectangle()
                    .fill(typeColor.opacity(0.3))
                    .frame(width: 2)
            }
            .frame(height: 60)
            
            // Content
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                HStack {
                    Text(correspondence.subject)
                        .font(AppTheme.Fonts.subheadlineMedium)
                    
                    Spacer()
                    
                    Text(correspondence.date, style: .time)
                        .font(.caption2)
                        .foregroundColor(AppTheme.Colors.secondary)
                }
                
                if let business = correspondence.business {
                    Text(business.name)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                }
                
                HStack(spacing: AppTheme.Spacing.sm) {
                    StatusBadge(correspondence.type.rawValue, color: typeColor)
                    
                    StatusBadge(
                        correspondence.direction.rawValue,
                        color: correspondence.direction == .inbound ? AppTheme.Colors.inbound : AppTheme.Colors.outbound
                    )
                }
                
                if !correspondence.content.isEmpty {
                    Text(correspondence.content)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                        .lineLimit(2)
                }
            }
            .padding(.vertical, AppTheme.Spacing.xs)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
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

struct CorrespondenceRow: View {
    let correspondence: Correspondence
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text(correspondence.subject)
                    .font(AppTheme.Fonts.headline)
                
                Spacer()
                
                Text(correspondence.date, style: .date)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
            
            Text(correspondence.business?.name ?? "Unknown Business")
                .font(AppTheme.Fonts.subheadline)
                .foregroundColor(AppTheme.Colors.secondary)
            
            HStack {
                StatusBadge(correspondence.type.rawValue, color: AppTheme.Colors.primary)
                
                StatusBadge(
                    correspondence.direction.rawValue,
                    color: correspondence.direction == .inbound ? AppTheme.Colors.inbound : AppTheme.Colors.outbound
                )
            }
            
            if !correspondence.content.isEmpty {
                Text(correspondence.content)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, AppTheme.Spacing.xs)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct CorrespondenceFilterChip: View {
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
    CorrespondenceView()
        .modelContainer(for: Correspondence.self, inMemory: true)
}
