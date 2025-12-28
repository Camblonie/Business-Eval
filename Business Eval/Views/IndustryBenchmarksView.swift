//
//  IndustryBenchmarksView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData
import Charts

struct IndustryBenchmarksView: View {
    let business: Business
    @State private var benchmark: IndustryBenchmark?
    @State private var analysis: BenchmarkAnalysis?
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if isLoading {
                    ProgressView("Loading industry benchmarks...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else if let benchmark = benchmark {
                    // Industry Overview
                    industryOverviewSection(benchmark: benchmark)
                    
                    // Multiple Comparison
                    multipleComparisonSection(benchmark: benchmark)
                    
                    // Business Metrics Comparison
                    metricsComparisonSection(benchmark: benchmark)
                    
                    // Risk Analysis
                    riskAnalysisSection(benchmark: benchmark)
                    
                    // Overall Assessment
                    if let analysis = analysis {
                        overallAssessmentSection(analysis: analysis)
                    }
                } else {
                    noBenchmarkView
                }
            }
            .padding()
        }
        .navigationTitle("Industry Benchmarks")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadBenchmarkData()
        }
    }
    
    private var noBenchmarkView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No Benchmark Data")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Industry benchmarks not available for \(business.industry)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private func industryOverviewSection(benchmark: IndustryBenchmark) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Industry Overview")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                OverviewRow(label: "Industry", value: benchmark.industry)
                OverviewRow(label: "Risk Level", value: benchmark.riskLevel.rawValue, color: riskColor(benchmark.riskLevel))
                OverviewRow(label: "Typical Growth Rate", value: "\(String(format: "%.1f", benchmark.typicalGrowthRate * 100))%")
                OverviewRow(label: "Average Business Size", value: "$\(benchmark.averageBusinessSize, specifier: "%.0f")")
                OverviewRow(label: "Last Updated", value: benchmark.lastUpdated, style: .date)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func multipleComparisonSection(benchmark: IndustryBenchmark) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Valuation Multiples Comparison")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                MultipleComparisonRow(
                    title: "Revenue Multiple",
                    industryValue: benchmark.revenueMultiple,
                    businessValue: business.annualRevenue > 0 ? business.askingPrice / business.annualRevenue : 0,
                    unit: "x"
                )
                
                MultipleComparisonRow(
                    title: "Profit Multiple",
                    industryValue: benchmark.profitMultiple,
                    businessValue: business.annualProfit > 0 ? business.askingPrice / business.annualProfit : 0,
                    unit: "x"
                )
                
                MultipleComparisonRow(
                    title: "EBITDA Multiple",
                    industryValue: benchmark.ebitdaMultiple,
                    businessValue: business.annualProfit > 0 ? business.askingPrice / business.annualProfit : 0,
                    unit: "x"
                )
                
                MultipleComparisonRow(
                    title: "SDE Multiple",
                    industryValue: benchmark.sdeMultiple,
                    businessValue: business.annualProfit > 0 ? business.askingPrice / business.annualProfit : 0,
                    unit: "x"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func metricsComparisonSection(benchmark: IndustryBenchmark) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Business Metrics Comparison")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                // Size comparison chart
                VStack(alignment: .leading, spacing: 8) {
                    Text("Business Size vs Industry Average")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        VStack {
                            Text("This Business")
                                .font(.caption)
                            Text("$\(business.annualRevenue, specifier: "%.0f")")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Text("Industry Avg")
                                .font(.caption)
                            Text("$\(benchmark.averageBusinessSize, specifier: "%.0f")")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Simple bar comparison
                    HStack(spacing: 20) {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: min(150, (business.annualRevenue / benchmark.averageBusinessSize) * 150), height: 20)
                        
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 150, height: 20)
                    }
                }
                
                // Growth rate comparison
                VStack(alignment: .leading, spacing: 8) {
                    Text("Growth Rate")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Text("Industry Growth: \(String(format: "%.1f", benchmark.typicalGrowthRate * 100))%")
                            .font(.caption)
                        
                        Spacer()
                        
                        let businessGrowth = calculateBusinessGrowth()
                        Text("Business Growth: \(String(format: "%.1f", businessGrowth * 100))%")
                            .font(.caption)
                            .foregroundColor(businessGrowth >= benchmark.typicalGrowthRate ? .green : .red)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func riskAnalysisSection(benchmark: IndustryBenchmark) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Risk Analysis")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Industry Risk Level")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text(benchmark.riskLevel.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(riskColor(benchmark.riskLevel).opacity(0.2))
                        .foregroundColor(riskColor(benchmark.riskLevel))
                        .cornerRadius(8)
                }
                
                Text(riskDescription(benchmark.riskLevel))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Risk factors
                VStack(alignment: .leading, spacing: 8) {
                    Text("Risk Factors")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    let riskFactors = getRiskFactors(benchmark: benchmark)
                    ForEach(riskFactors, id: \.self) { factor in
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                                .font(.caption)
                            
                            Text(factor)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func overallAssessmentSection(analysis: BenchmarkAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overall Assessment")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                // Score indicator
                VStack(spacing: 8) {
                    HStack {
                        Text("Industry Fit Score")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(String(format: "%.0f", analysis.overallScore * 100))%")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(scoreColor(analysis.overallScore))
                    }
                    
                    ProgressView(value: analysis.overallScore)
                        .progressViewStyle(LinearProgressViewStyle(tint: scoreColor(analysis.overallScore)))
                }
                
                // Recommendation
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommendation")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(analysis.recommendation)
                        .font(.body)
                        .foregroundColor(scoreColor(analysis.overallScore))
                        .padding()
                        .background(scoreColor(analysis.overallScore).opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Key insights
                VStack(alignment: .leading, spacing: 8) {
                    Text("Key Insights")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    let insights = getKeyInsights(analysis: analysis)
                    ForEach(insights, id: \.self) { insight in
                        HStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 6, height: 6)
                            
                            Text(insight)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // Helper functions
    private func loadBenchmarkData() {
        let service = IndustryBenchmarkService.shared
        benchmark = service.getBenchmark(for: business.industry)
        
        if let benchmark = benchmark {
            analysis = service.getComparisonAnalysis(business: business, benchmark: benchmark)
        }
        
        isLoading = false
    }
    
    private func calculateBusinessGrowth() -> Double {
        // This would ideally use historical data
        // For now, estimate based on profit margin and industry
        let profitMargin = business.annualRevenue > 0 ? business.annualProfit / business.annualRevenue : 0
        return profitMargin * 0.5 // Simple estimation
    }
    
    private func riskColor(_ level: RiskLevel) -> Color {
        switch level {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        case .veryHigh: return .red
        }
    }
    
    private func riskDescription(_ level: RiskLevel) -> String {
        switch level {
        case .low:
            return "Low risk industry with stable demand and predictable returns"
        case .medium:
            return "Moderate risk with some market volatility and competition"
        case .high:
            return "High risk industry with significant competition and market changes"
        case .veryHigh:
            return "Very high risk with rapid market changes and uncertainty"
        }
    }
    
    private func getRiskFactors(benchmark: IndustryBenchmark) -> [String] {
        var factors: [String] = []
        
        switch benchmark.riskLevel {
        case .low:
            factors.append("Stable market demand")
            factors.append("Predictable cash flows")
        case .medium:
            factors.append("Moderate competition")
            factors.append("Some regulatory changes")
        case .high:
            factors.append("High competition")
            factors.append("Market volatility")
        case .veryHigh:
            factors.append("Rapid technological change")
            factors.append("Regulatory uncertainty")
            factors.append("High capital requirements")
        }
        
        return factors
    }
    
    private func scoreColor(_ score: Double) -> Color {
        switch score {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .orange
        default: return .red
        }
    }
    
    private func getKeyInsights(analysis: BenchmarkAnalysis) -> [String] {
        var insights: [String] = []
        
        if analysis.revenueMultipleComparison > 1.2 {
            insights.append("Business is priced above industry revenue multiple")
        } else if analysis.revenueMultipleComparison < 0.8 {
            insights.append("Business is priced below industry revenue multiple")
        }
        
        if analysis.sizeComparison > 1.5 {
            insights.append("Business is larger than typical industry average")
        } else if analysis.sizeComparison < 0.5 {
            insights.append("Business is smaller than typical industry average")
        }
        
        if analysis.growthComparison > 1.2 {
            insights.append("Business growth exceeds industry average")
        } else if analysis.growthComparison < 0.8 {
            insights.append("Business growth below industry average")
        }
        
        return insights
    }
}

struct OverviewRow: View {
    let label: String
    let value: String
    let color: Color
    let style: Text.DateStyle?
    
    init(label: String, value: String, color: Color = .primary, style: Text.DateStyle? = nil) {
        self.label = label
        self.value = value
        self.color = color
        self.style = style
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if let style = style {
                Text(value, style: style)
                    .font(.subheadline)
                    .foregroundColor(color)
            } else {
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(color)
            }
        }
    }
}

struct MultipleComparisonRow: View {
    let title: String
    let industryValue: Double
    let businessValue: Double
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Industry")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(industryValue, specifier: "%.1f")\(unit)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .trailing) {
                    Text("This Business")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(businessValue, specifier: "%.1f")\(unit)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            // Comparison indicator
            HStack {
                Spacer()
                
                if businessValue > 0 {
                    let comparison = businessValue / industryValue
                    Text("\(comparison >= 1.2 ? "Above" : comparison <= 0.8 ? "Below" : "Matches") Industry")
                        .font(.caption2)
                        .foregroundColor(comparison >= 1.2 ? .red : comparison <= 0.8 ? .green : .blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background((comparison >= 1.2 ? Color.red : comparison <= 0.8 ? Color.green : Color.blue).opacity(0.2))
                        .cornerRadius(4)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
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
    
    return IndustryBenchmarksView(business: business)
}
