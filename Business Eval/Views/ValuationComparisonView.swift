//
//  ValuationComparisonView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData
import Charts

struct ValuationComparisonView: View {
    let business: Business
    @Query private var valuations: [Valuation]
    
    private var businessValuations: [Valuation] {
        valuations.filter { $0.business?.id == business.id }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                headerSection
                
                if businessValuations.count < 2 {
                    insufficientValuationsView
                } else {
                    // Comparison Chart
                    chartSection
                    
                    // Valuation Comparison Table
                    comparisonTableSection
                    
                    // Analysis Summary
                    analysisSection
                }
            }
            .padding()
        }
        .navigationTitle("Valuation Comparison")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(business.name)
                .font(.title2)
                .fontWeight(.bold)
            
            Text("\(businessValuations.count) valuation\(businessValuations.count == 1 ? "" : "s")")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var insufficientValuationsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("Need at least 2 valuations to compare")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add more valuations to see comparison analysis")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Valuation Trend")
                .font(.headline)
                .fontWeight(.bold)
            
            Chart {
                ForEach(Array(businessValuations.enumerated()), id: \.offset) { index, valuation in
                    LineMark(
                        x: .value("Date", valuation.createdAt),
                        y: .value("Value", valuation.calculatedValue)
                    )
                    .foregroundStyle(Color.blue)
                    .symbol(Circle().strokeBorder(lineWidth: 2))
                }
                
                ForEach(Array(businessValuations.enumerated()), id: \.offset) { index, valuation in
                    PointMark(
                        x: .value("Date", valuation.createdAt),
                        y: .value("Value", valuation.calculatedValue)
                    )
                    .foregroundStyle(Color.blue)
                    .symbolSize(50)
                }
                
                // Asking price reference line
                RuleMark(
                    y: .value("Asking Price", business.askingPrice)
                )
                .foregroundStyle(Color.green)
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                .annotation(position: .top) {
                    Text("Asking: $\(business.askingPrice, specifier: "%.0f")")
                        .font(.caption)
                        .foregroundColor(.green)
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
                    AxisValueLabel(format: .currency(code: "USD"))
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var comparisonTableSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detailed Comparison")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Date")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Method")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Value")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text("Multiple")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text("Confidence")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray5))
                
                // Rows
                ForEach(businessValuations, id: \.id) { valuation in
                    HStack {
                        Text(valuation.createdAt, style: .date)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(valuation.methodology.rawValue)
                            .font(.caption)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("$\(valuation.calculatedValue, specifier: "%.0f")")
                            .font(.caption)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Text("\(valuation.multiple, specifier: "%.1f")x")
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        HStack {
                            Circle()
                                .fill(confidenceColor(for: valuation))
                                .frame(width: 8, height: 8)
                            
                            Text(valuation.confidenceLevel.rawValue)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(valuation === businessValuations.first ? Color.blue.opacity(0.1) : Color.clear)
                }
            }
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var analysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analysis Summary")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                ComparisonAnalysisRow(
                    title: "Average Valuation",
                    value: "$\(String(format: "%.0f", averageValuation))",
                    color: .blue
                )
                
                ComparisonAnalysisRow(
                    title: "Value Range",
                    value: "$\(String(format: "%.0f", minValuation)) - $\(String(format: "%.0f", maxValuation))",
                    color: .gray
                )
                
                ComparisonAnalysisRow(
                    title: "Value Variance",
                    value: "$\(String(format: "%.0f", valueVariance)) (\(String(format: "%.1f", variancePercentage))%)",
                    color: valueVariance > averageValuation * 0.2 ? .orange : .green
                )
                
                ComparisonAnalysisRow(
                    title: "vs Asking Price",
                    value: "$\(String(format: "%.0f", askingPriceDifference)) (\(String(format: "%.1f", askingPricePercentage))%)",
                    color: askingPriceDifference >= 0 ? .green : .red
                )
                
                ComparisonAnalysisRow(
                    title: "Average Confidence",
                    value: averageConfidenceLevel,
                    color: confidenceColor
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // Computed properties
    private var averageValuation: Double {
        guard !businessValuations.isEmpty else { return 0 }
        return businessValuations.reduce(0) { $0 + $1.calculatedValue } / Double(businessValuations.count)
    }
    
    private var minValuation: Double {
        businessValuations.map(\.calculatedValue).min() ?? 0
    }
    
    private var maxValuation: Double {
        businessValuations.map(\.calculatedValue).max() ?? 0
    }
    
    private var valueVariance: Double {
        maxValuation - minValuation
    }
    
    private var variancePercentage: Double {
        guard averageValuation > 0 else { return 0 }
        return (valueVariance / averageValuation) * 100
    }
    
    private var askingPriceDifference: Double {
        averageValuation - business.askingPrice
    }
    
    private var askingPricePercentage: Double {
        guard business.askingPrice > 0 else { return 0 }
        return (askingPriceDifference / business.askingPrice) * 100
    }
    
    private var averageConfidenceLevel: String {
        let confidenceScores = businessValuations.map { valuation in
            switch valuation.confidenceLevel {
            case .low: return 1
            case .medium: return 2
            case .high: return 3
            case .veryHigh: return 4
            }
        }
        
        let average = confidenceScores.reduce(0, +) / Double(confidenceScores.count)
        
        switch average {
        case 0..<1.5: return "Low"
        case 1.5..<2.5: return "Medium"
        case 2.5..<3.5: return "High"
        default: return "Very High"
        }
    }
    
    private var confidenceColor: Color {
        let level = averageConfidenceLevel
        switch level {
        case "Low": return .red
        case "Medium": return .orange
        case "High": return .green
        default: return .blue
        }
    }
    
    private func confidenceColor(for valuation: Valuation) -> Color {
        switch valuation.confidenceLevel {
        case .low: return .red
        case .medium: return .orange
        case .high: return .green
        case .veryHigh: return .blue
        }
    }
}

struct ComparisonAnalysisRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

#Preview {
    let business = Business(
        name: "Test Business",
        industry: "Technology",
        location: "San Francisco, CA",
        askingPrice: 500000,
        annualRevenue: 1000000,
        annualProfit: 200000,
        numberOfEmployees: 10,
        yearsEstablished: 5,
        businessDescription: "A test business for demonstration purposes."
    )
    
    return ValuationComparisonView(business: business)
        .modelContainer(for: [Business.self, Valuation.self], inMemory: true)
}
