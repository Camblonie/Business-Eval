//
//  ValuationAnalyticsView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData
import Charts

struct ValuationAnalyticsView: View {
    @Query private var valuations: [Valuation]
    @Query private var businesses: [Business]
    @State private var selectedTimeRange: TimeRange = .all
    @State private var selectedChartType: ChartType = .valueTrend
    
    enum TimeRange: String, CaseIterable {
        case all = "All Time"
        case year = "Last Year"
        case month = "Last Month"
        case week = "Last Week"
    }
    
    enum ChartType: String, CaseIterable {
        case valueTrend = "Value Trend"
        case methodology = "Methodology Distribution"
        case confidence = "Confidence Analysis"
        case industry = "Industry Comparison"
    }
    
    private var filteredValuations: [Valuation] {
        let cutoffDate: Date
        let now = Date()
        
        switch selectedTimeRange {
        case .all:
            cutoffDate = Date.distantPast
        case .year:
            cutoffDate = Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now
        case .month:
            cutoffDate = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
        case .week:
            cutoffDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        }
        
        return valuations.filter { $0.createdAt >= cutoffDate }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with filters
                headerSection
                
                // Summary cards
                summaryCardsSection
                
                // Main chart
                mainChartSection
                
                // Additional analytics
                additionalAnalyticsSection
            }
            .padding()
        }
        .navigationTitle("Valuation Analytics")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analytics Overview")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                // Time range selector
                Menu {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Button(range.rawValue) {
                            selectedTimeRange = range
                        }
                    }
                } label: {
                    FilterChip(title: selectedTimeRange.rawValue, isSelected: true)
                }
                
                // Chart type selector
                Menu {
                    ForEach(ChartType.allCases, id: \.self) { type in
                        Button(type.rawValue) {
                            selectedChartType = type
                        }
                    }
                } label: {
                    FilterChip(title: selectedChartType.rawValue, isSelected: true)
                }
                
                Spacer()
            }
        }
    }
    
    private var summaryCardsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            AnalyticsCard(
                title: "Total Valuations",
                value: "\(filteredValuations.count)",
                subtitle: selectedTimeRange.rawValue,
                color: .blue
            )
            
            AnalyticsCard(
                title: "Average Value",
                value: "$\(String(format: "%.0f", averageValuation))",
                subtitle: "Across all valuations",
                color: .green
            )
            
            AnalyticsCard(
                title: "Avg Multiple",
                value: "\(String(format: "%.1f", averageMultiple))x",
                subtitle: "Revenue/Profit multiples",
                color: .orange
            )
            
            AnalyticsCard(
                title: "Avg Confidence",
                value: averageConfidenceLevel,
                subtitle: "Confidence rating",
                color: .purple
            )
        }
    }
    
    private var mainChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Valuation Trends")
                .font(.headline)
                .fontWeight(.bold)
            
            switch selectedChartType {
            case .valueTrend:
                valueTrendChart
            case .methodology:
                methodologyChart
            case .confidence:
                confidenceChart
            case .industry:
                industryChart
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var valueTrendChart: some View {
        Chart {
            ForEach(Array(filteredValuations.sorted(by: { $0.createdAt < $1.createdAt }).enumerated()), id: \.offset) { index, valuation in
                LineMark(
                    x: .value("Date", valuation.createdAt),
                    y: .value("Value", valuation.calculatedValue)
                )
                .foregroundStyle(Color.blue)
                .symbol(Circle().strokeBorder(lineWidth: 2))
            }
            
            ForEach(Array(filteredValuations.sorted(by: { $0.createdAt < $1.createdAt }).enumerated()), id: \.offset) { index, valuation in
                PointMark(
                    x: .value("Date", valuation.createdAt),
                    y: .value("Value", valuation.calculatedValue)
                )
                .foregroundStyle(Color.blue)
                .symbolSize(50)
            }
        }
        .frame(height: 250)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel(format: .currency(code: "USD"))
            }
        }
    }
    
    private var methodologyChart: some View {
        Chart {
            ForEach(methodologyData, id: \.methodology) { data in
                SectorMark(
                    angle: .value("Count", data.count),
                    innerRadius: .ratio(0.4),
                    angularInset: 2
                )
                .foregroundStyle(by: .value("Methodology", data.methodology.rawValue))
                .opacity(0.8)
            }
        }
        .frame(height: 250)
        .chartLegend(position: .bottom, alignment: .center)
    }
    
    private var confidenceChart: some View {
        Chart {
            ForEach(confidenceData, id: \.level) { data in
                BarMark(
                    x: .value("Confidence", data.level.rawValue),
                    y: .value("Count", data.count)
                )
                .foregroundStyle(confidenceColor(data.level))
            }
        }
        .frame(height: 250)
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
    
    private var industryChart: some View {
        Chart {
            ForEach(industryData, id: \.industry) { data in
                BarMark(
                    x: .value("Industry", data.industry),
                    y: .value("Average Value", data.averageValue)
                )
                .foregroundStyle(Color.blue)
            }
        }
        .frame(height: 250)
        .chartXAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel()
                    .font(.caption)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel(format: .currency(code: "USD"))
            }
        }
    }
    
    private var additionalAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Insights")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                InsightRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Value Trend",
                    description: valueTrendInsight
                )
                
                InsightRow(
                    icon: "chart.bar.fill",
                    title: "Popular Methods",
                    description: popularMethodologyInsight
                )
                
                InsightRow(
                    icon: "star.fill",
                    title: "Confidence Patterns",
                    description: confidenceInsight
                )
                
                InsightRow(
                    icon: "building.2.fill",
                    title: "Industry Focus",
                    description: industryInsight
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // Computed properties
    private var averageValuation: Double {
        guard !filteredValuations.isEmpty else { return 0 }
        return filteredValuations.reduce(0) { $0 + $1.calculatedValue } / Double(filteredValuations.count)
    }
    
    private var averageMultiple: Double {
        guard !filteredValuations.isEmpty else { return 0 }
        return filteredValuations.reduce(0) { $0 + $1.multiple } / Double(filteredValuations.count)
    }
    
    private var averageConfidenceLevel: String {
        let confidenceScores = filteredValuations.map { valuation in
            switch valuation.confidenceLevel {
            case .low: return 1
            case .medium: return 2
            case .high: return 3
            case .veryHigh: return 4
            }
        }
        
        guard !confidenceScores.isEmpty else { return "N/A" }
        let average = Double(confidenceScores.reduce(0) { $0 + $1 }) / Double(confidenceScores.count)
        
        switch average {
        case 0..<1.5: return "Low"
        case 1.5..<2.5: return "Medium"
        case 2.5..<3.5: return "High"
        default: return "Very High"
        }
    }
    
    private var methodologyData: [(methodology: ValuationMethodology, count: Int)] {
        let grouped = Dictionary(grouping: filteredValuations, by: { $0.methodology })
        return grouped.map { (methodology: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }
    
    private var confidenceData: [(level: ConfidenceLevel, count: Int)] {
        let grouped = Dictionary(grouping: filteredValuations, by: { $0.confidenceLevel })
        return grouped.map { (level: $0.key, count: $0.value.count) }
            .sorted { confidenceOrder($0.level) > confidenceOrder($1.level) }
    }
    
    private var industryData: [(industry: String, averageValue: Double)] {
        let grouped = Dictionary(grouping: filteredValuations) { valuation in
            valuation.business?.industry ?? "Unknown"
        }
        
        return grouped.map { (industry: $0.key, valuations: $0.value) }
            .map { (industry: $0.industry, averageValue: $0.valuations.reduce(0) { $0 + $1.calculatedValue } / Double($0.valuations.count)) }
            .sorted { $0.averageValue > $1.averageValue }
            .prefix(5)
            .map { $0 }
    }
    
    private var valueTrendInsight: String {
        guard filteredValuations.count >= 2 else { return "Insufficient data for trend analysis" }
        
        let sorted = filteredValuations.sorted { $0.createdAt < $1.createdAt }
        let firstValue = sorted.first!.calculatedValue
        let lastValue = sorted.last!.calculatedValue
        let change = ((lastValue - firstValue) / firstValue) * 100
        
        if change > 10 {
            return "Valuations trending upward (+\(String(format: "%.1f", change))%)"
        } else if change < -10 {
            return "Valuations trending downward (\(String(format: "%.1f", change))%)"
        } else {
            return "Valuations relatively stable"
        }
    }
    
    private var popularMethodologyInsight: String {
        guard !methodologyData.isEmpty else { return "No valuation data available" }
        let top = methodologyData.first!
        return "\(top.methodology.rawValue) is most used (\(top.count) times)"
    }
    
    private var confidenceInsight: String {
        let highConfidence = filteredValuations.filter { $0.confidenceLevel == .high || $0.confidenceLevel == .veryHigh }.count
        let percentage = filteredValuations.isEmpty ? 0 : (Double(highConfidence) / Double(filteredValuations.count)) * 100
        
        if percentage > 70 {
            return "High confidence in valuations (\(String(format: "%.0f", percentage))%)"
        } else if percentage < 30 {
            return "Low confidence in valuations (\(String(format: "%.0f", percentage))%)"
        } else {
            return "Moderate confidence levels"
        }
    }
    
    private var industryInsight: String {
        guard !industryData.isEmpty else { return "No industry data available" }
        let topIndustry = industryData.first!
        return "\(topIndustry.industry) has highest average valuations ($\(String(format: "%.0f", topIndustry.averageValue)))"
    }
    
    private func confidenceOrder(_ level: ConfidenceLevel) -> Int {
        switch level {
        case .veryHigh: return 4
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
    
    private func confidenceColor(_ level: ConfidenceLevel) -> Color {
        switch level {
        case .low: return .red
        case .medium: return .orange
        case .high: return .green
        case .veryHigh: return .blue
        }
    }
}

struct AnalyticsCard: View {
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

struct InsightRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
    }
}

#Preview {
    ValuationAnalyticsView()
        .modelContainer(for: [Valuation.self, Business.self], inMemory: true)
}
