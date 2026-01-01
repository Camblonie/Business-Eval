//
//  CorrespondenceAnalyticsView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/29/25.
//

import SwiftUI
import SwiftData
import Charts

struct CorrespondenceAnalyticsView: View {
    @Query private var correspondence: [Correspondence]
    @Query private var businesses: [Business]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Summary Cards
                summaryCardsSection
                
                // Correspondence Types Chart
                correspondenceTypesSection
                
                // Direction Analysis
                directionAnalysisSection
                
                // Business Activity
                businessActivitySection
                
                // Timeline Activity
                timelineActivitySection
            }
            .padding()
        }
        .navigationTitle("Correspondence Analytics")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var summaryCardsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            AnalyticsCard(
                title: "Total Correspondence",
                value: "\(correspondence.count)",
                subtitle: "All types",
                color: .blue
            )
            
            AnalyticsCard(
                title: "This Week",
                value: "\(thisWeekCount)",
                subtitle: "Correspondence items",
                color: .green
            )
            
            AnalyticsCard(
                title: "Response Rate",
                value: "\(String(format: "%.0f", responseRate))%",
                subtitle: "Inbound vs Outbound",
                color: .orange
            )
            
            AnalyticsCard(
                title: "Active Businesses",
                value: "\(activeBusinesses)",
                subtitle: "With correspondence",
                color: .purple
            )
        }
    }
    
    private var correspondenceTypesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Correspondence Types")
                .font(.headline)
                .fontWeight(.bold)
            
            Chart {
                ForEach(typeData, id: \.type) { data in
                    SectorMark(
                        angle: .value("Count", data.count),
                        innerRadius: .ratio(0.4),
                        angularInset: 2
                    )
                    .foregroundStyle(by: .value("Type", data.type.rawValue))
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
    
    private var directionAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Direction Analysis")
                .font(.headline)
                .fontWeight(.bold)
            
            Chart {
                ForEach(directionData, id: \.direction) { data in
                    BarMark(
                        x: .value("Direction", data.direction.rawValue),
                        y: .value("Count", data.count)
                    )
                    .foregroundStyle(data.direction == .inbound ? Color.green : Color.orange)
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
    
    private var businessActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Business Activity")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                ForEach(topBusinesses.prefix(5), id: \.business.id) { data in
                    HStack {
                        Text(data.business.name)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(data.count)")
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
    
    private var timelineActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Timeline")
                .font(.headline)
                .fontWeight(.bold)
            
            Chart {
                ForEach(timelineData, id: \.date) { data in
                    LineMark(
                        x: .value("Date", data.date),
                        y: .value("Count", data.count)
                    )
                    .foregroundStyle(Color.blue)
                    .symbol(Circle().strokeBorder(lineWidth: 2))
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
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
    
    // Computed Properties
    private var thisWeekCount: Int {
        let calendar = Calendar.current
        let now = Date()
        return correspondence.filter { item in
            calendar.isDate(item.date, equalTo: now, toGranularity: .weekOfYear)
        }.count
    }
    
    private var responseRate: Double {
        let inbound = correspondence.filter { $0.direction == .inbound }.count
        let outbound = correspondence.filter { $0.direction == .outbound }.count
        
        guard outbound > 0 else { return 0 }
        return (Double(inbound) / Double(outbound)) * 100
    }
    
    private var activeBusinesses: Int {
        let businessIds = Set(correspondence.compactMap { $0.business?.id })
        return businessIds.count
    }
    
    private var typeData: [(type: CorrespondenceType, count: Int)] {
        CorrespondenceType.allCases.map { type in
            (type: type, count: correspondence.filter { $0.type == type }.count)
        }
    }
    
    private var directionData: [(direction: CorrespondenceDirection, count: Int)] {
        CorrespondenceDirection.allCases.map { direction in
            (direction: direction, count: correspondence.filter { $0.direction == direction }.count)
        }
    }
    
    private var topBusinesses: [(business: Business, count: Int)] {
        let businessGroups = Dictionary(grouping: correspondence.compactMap { $0.business }) { $0 }
        return businessGroups.map { (business: $0.key, correspondence: $0.value) }
            .map { (business: $0.business, count: $0.correspondence.count) }
            .sorted { $0.count > $1.count }
    }
    
    private var timelineData: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: correspondence) { item in
            calendar.startOfDay(for: item.date)
        }
        
        return grouped.map { (date: $0.key, count: $0.value.count) }
            .sorted { $0.date < $1.date }
            .suffix(30) // Last 30 days
    }
}

// Reuse AnalyticsCard from other views or create local version
struct CorrespondenceAnalyticsCard: View {
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
    CorrespondenceAnalyticsView()
        .modelContainer(for: [Correspondence.self, Business.self], inMemory: true)
}
