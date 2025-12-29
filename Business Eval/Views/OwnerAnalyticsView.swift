//
//  OwnerAnalyticsView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/29/25.
//

import SwiftUI
import SwiftData
import Charts

struct OwnerAnalyticsView: View {
    @Query private var owners: [Owner]
    @Query private var businesses: [Business]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Summary Cards
                summaryCardsSection
                
                // Owner Distribution Chart
                ownerDistributionSection
                
                // Contact Preferences Analysis
                contactPreferencesSection
                
                // Top Owners by Business Count
                topOwnersSection
                
                // Industry Insights
                industryInsightsSection
            }
            .padding()
        }
        .navigationTitle("Owner Analytics")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var summaryCardsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            AnalyticsCard(
                title: "Total Owners",
                value: "\(owners.count)",
                subtitle: "In database",
                color: .blue
            )
            
            AnalyticsCard(
                title: "Avg Businesses",
                value: String(format: "%.1f", averageBusinessesPerOwner),
                subtitle: "Per owner",
                color: .green
            )
            
            AnalyticsCard(
                title: "Multi-Business",
                value: "\(multiBusinessOwners.count)",
                subtitle: "Owners with 2+ businesses",
                color: .orange
            )
            
            AnalyticsCard(
                title: "Contact Rate",
                value: "\(String(format: "%.0f", contactRate))%",
                subtitle: "Have contact info",
                color: .purple
            )
        }
    }
    
    private var ownerDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Owner Distribution")
                .font(.headline)
                .fontWeight(.bold)
            
            Chart {
                ForEach(ownerBusinessDistribution, id: \.category) { data in
                    BarMark(
                        x: .value("Category", data.category),
                        y: .value("Count", data.count)
                    )
                    .foregroundStyle(data.color)
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var contactPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact Preferences")
                .font(.headline)
                .fontWeight(.bold)
            
            Chart {
                ForEach(contactPreferenceData, id: \.preference) { data in
                    SectorMark(
                        angle: .value("Count", data.count),
                        innerRadius: .ratio(0.4),
                        angularInset: 2
                    )
                    .foregroundStyle(by: .value("Preference", data.preference.rawValue))
                    .opacity(0.8)
                }
            }
            .frame(height: 200)
            .chartLegend(position: .bottom, alignment: .center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var topOwnersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Owners by Business Count")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                ForEach(topOwners.prefix(5), id: \.owner.id) { data in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(data.owner.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            if let title = data.owner.title {
                                Text(title)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Text("\(data.businessCount) businesses")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var industryInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Industry Insights")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                ForEach(industryData.prefix(5), id: \.industry) { data in
                    HStack {
                        Text(data.industry)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(data.ownerCount) owners")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // Computed Properties
    private var averageBusinessesPerOwner: Double {
        guard !owners.isEmpty else { return 0 }
        let totalBusinesses = owners.reduce(0) { $0 + $1.businesses.count }
        return Double(totalBusinesses) / Double(owners.count)
    }
    
    private var multiBusinessOwners: [Owner] {
        owners.filter { $0.businesses.count >= 2 }
    }
    
    private var contactRate: Double {
        guard !owners.isEmpty else { return 0 }
        let ownersWithContact = owners.filter { 
            ($0.email != nil) || ($0.phone != nil) 
        }
        return (Double(ownersWithContact.count) / Double(owners.count)) * 100
    }
    
    private var ownerBusinessDistribution: [(category: String, count: Int, color: Color)] {
        let noBusiness = owners.filter { $0.businesses.count == 0 }.count
        let oneBusiness = owners.filter { $0.businesses.count == 1 }.count
        let multipleBusinesses = owners.filter { $0.businesses.count > 1 }.count
        
        return [
            ("No Businesses", noBusiness, .red),
            ("1 Business", oneBusiness, .blue),
            ("2+ Businesses", multipleBusinesses, .green)
        ]
    }
    
    private var contactPreferenceData: [(preference: ContactPreference, count: Int)] {
        ContactPreference.allCases.map { preference in
            (preference: preference, count: owners.filter { $0.contactPreference == preference }.count)
        }
    }
    
    private var topOwners: [(owner: Owner, businessCount: Int)] {
        owners
            .map { (owner: $0, businessCount: $0.businesses.count) }
            .sorted { $0.businessCount > $1.businessCount }
    }
    
    private var industryData: [(industry: String, ownerCount: Int)] {
        let industryGroups = Dictionary(grouping: owners.flatMap { $0.businesses }) { $0.industry }
        return industryGroups.map { (industry: $0.key, businesses: $0.value) }
            .map { (industry: $0.industry, ownerCount: Set($0.businesses.compactMap { $0.owner }).count) }
            .sorted { $0.ownerCount > $1.ownerCount }
    }
}

// Reuse AnalyticsCard from earlier or create a local version
struct OwnerAnalyticsCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    OwnerAnalyticsView()
        .modelContainer(for: [Owner.self, Business.self], inMemory: true)
}
