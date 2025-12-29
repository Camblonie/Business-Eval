//
//  ValuationScenariosView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData
import Charts

struct ValuationScenariosView: View {
    let business: Business
    @Environment(\.modelContext) private var modelContext
    @State private var scenarios: [ValuationScenario] = []
    @State private var analysis: ScenarioAnalysis?
    @State private var showingAddScenario = false
    @State private var selectedScenario: ValuationScenario?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if isLoading {
                        ProgressView("Generating scenarios...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                    } else {
                        // Scenario Overview
                        scenarioOverviewSection
                        
                        // Scenario Comparison Chart
                        scenarioChartSection
                        
                        // Scenario Details
                        scenarioDetailsSection
                        
                        // Risk Analysis
                        riskAnalysisSection
                        
                        // Investment Recommendation
                        if let analysis = analysis {
                            investmentRecommendationSection(analysis: analysis)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Valuation Scenarios")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddScenario = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddScenario) {
                AddScenarioView(business: business) { newScenario in
                    scenarios.append(newScenario)
                    updateAnalysis()
                }
            }
            .onAppear {
                generateDefaultScenarios()
            }
        }
    }
    
    private var scenarioOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Scenario Overview")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(scenarios, id: \.id) { scenario in
                    ScenarioCard(scenario: scenario) {
                        selectedScenario = scenario
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var scenarioChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Scenario Comparison")
                .font(.headline)
                .fontWeight(.bold)
            
            Chart {
                ForEach(scenarios, id: \.id) { scenario in
                    BarMark(
                        x: .value("Scenario", scenario.scenarioType.rawValue),
                        y: .value("Value", scenario.calculatedValue)
                    )
                    .foregroundStyle(scenarioColor(scenario.scenarioType))
                    .opacity(0.8)
                }
                
                // Asking price reference line
                if business.askingPrice > 0 {
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
                    AxisValueLabel(format: .currency(code: "USD"))
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var scenarioDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Scenario Details")
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(scenarios, id: \.id) { scenario in
                ScenarioDetailRow(scenario: scenario) {
                    selectedScenario = scenario
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var riskAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Risk Analysis")
                .font(.headline)
                .fontWeight(.bold)
            
            if let analysis = analysis {
                VStack(spacing: 16) {
                    // Value range indicator
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Value Range")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        HStack {
                            Text("$\(analysis.pessimisticValue, specifier: "%.0f")")
                                .font(.caption)
                                .foregroundColor(.red)
                            
                            Rectangle()
                                .fill(LinearGradient(
                                    colors: [.red, .orange, .green],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Text("$\(analysis.optimisticValue, specifier: "%.0f")")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        
                        Text("Range: $\(analysis.valueRange, specifier: "%.0f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Risk metrics
                    VStack(spacing: 8) {
                        RiskMetricRow(
                            title: "Risk Level",
                            value: analysis.riskLevel,
                            color: riskColor(analysis.riskLevel)
                        )
                        
                        RiskMetricRow(
                            title: "Risk Premium",
                            value: "\(String(format: "%.1f", analysis.riskPremium * 100))%",
                            color: .orange
                        )
                        
                        RiskMetricRow(
                            title: "Volatility",
                            value: volatilityDescription(analysis.valueRange / analysis.realisticValue),
                            color: .blue
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func investmentRecommendationSection(analysis: ScenarioAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Investment Recommendation")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                // Recommendation
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommendation")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(analysis.investmentRecommendation)
                        .font(.body)
                        .foregroundColor(recommendationColor(analysis.investmentRecommendation))
                        .padding()
                        .background(recommendationColor(analysis.investmentRecommendation).opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Key metrics
                VStack(spacing: 8) {
                    Text("Key Metrics")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    let upsidePotential = (analysis.optimisticValue - analysis.realisticValue) / analysis.realisticValue
                    let downsideRisk = (analysis.realisticValue - analysis.pessimisticValue) / analysis.realisticValue
                    
                    HStack {
                        MetricCard(
                            title: "Upside Potential",
                            value: "\(String(format: "%.1f", upsidePotential * 100))%",
                            color: .green
                        )
                        
                        MetricCard(
                            title: "Downside Risk",
                            value: "\(String(format: "%.1f", downsideRisk * 100))%",
                            color: .red
                        )
                        
                        MetricCard(
                            title: "Risk/Reward",
                            value: String(format: "%.1f", upsidePotential / (downsideRisk > 0 ? downsideRisk : 0.1)),
                            color: .blue
                        )
                    }
                }
                
                // Recommended action
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommended Offer")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Text("$\(analysis.recommendedValue, specifier: "%.0f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        let vsAsking = analysis.recommendedValue - business.askingPrice
                        Text("\(vsAsking >= 0 ? "+" : "")$\(vsAsking, specifier: "%.0f") vs asking")
                            .font(.caption)
                            .foregroundColor(vsAsking >= 0 ? .green : .red)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // Helper functions
    private func generateDefaultScenarios() {
        let service = ValuationScenarioService.shared
        
        // Use the most recent valuation as base, or asking price
        let baseValuation = business.valuations.first?.calculatedValue ?? business.askingPrice
        
        scenarios = service.generateScenarios(for: business, baseValuation: baseValuation)
        updateAnalysis()
        isLoading = false
    }
    
    private func updateAnalysis() {
        let service = ValuationScenarioService.shared
        analysis = service.getScenarioAnalysis(scenarios: scenarios)
    }
    
    private func scenarioColor(_ type: ScenarioType) -> Color {
        switch type {
        case .optimistic: return .green
        case .realistic: return .blue
        case .pessimistic: return .red
        case .custom: return .purple
        }
    }
    
    private func riskColor(_ level: String) -> Color {
        switch level {
        case "Low Risk": return .green
        case "Medium Risk": return .orange
        default: return .red
        }
    }
    
    private func volatilityDescription(_ ratio: Double) -> String {
        switch ratio {
        case 0..<0.3: return "Low"
        case 0.3..<0.6: return "Medium"
        default: return "High"
        }
    }
    
    private func recommendationColor(_ recommendation: String) -> Color {
        if recommendation.contains("Strong Buy") {
            return .green
        } else if recommendation.contains("Buy") {
            return .blue
        } else if recommendation.contains("Consider") {
            return .orange
        } else {
            return .red
        }
    }
}

struct ScenarioCard: View {
    let scenario: ValuationScenario
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(scenario.scenarioType.rawValue)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(scenarioColor(scenario.scenarioType))
            
            Text("$\(scenario.calculatedValue, specifier: "%.0f")")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("\(String(format: "%.1f", ((scenario.calculatedValue - (scenario.business?.askingPrice ?? 0)) / (scenario.business?.askingPrice ?? 1)) * 100))%")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(scenarioColor(scenario.scenarioType), lineWidth: 1)
        )
        .onTapGesture {
            onTap()
        }
    }
    
    private func scenarioColor(_ type: ScenarioType) -> Color {
        switch type {
        case .optimistic: return .green
        case .realistic: return .blue
        case .pessimistic: return .red
        case .custom: return .purple
        }
    }
}

struct ScenarioDetailRow: View {
    let scenario: ValuationScenario
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(scenario.scenarioType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(scenarioColor(scenario.scenarioType))
                
                Spacer()
                
                Text("$\(scenario.calculatedValue, specifier: "%.0f")")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            
            if let assumptions = scenario.assumptions {
                Text(assumptions)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Text("Growth: \(String(format: "%.1f", scenario.growthRate * 100))%")
                    .font(.caption2)
                
                Spacer()
                
                Text("Risk: \(String(format: "%.1f", scenario.riskAdjustment * 100))%")
                    .font(.caption2)
                
                Spacer()
                
                Text(scenario.marketConditions.rawValue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .onTapGesture {
            onTap()
        }
    }
    
    private func scenarioColor(_ type: ScenarioType) -> Color {
        switch type {
        case .optimistic: return .green
        case .realistic: return .blue
        case .pessimistic: return .red
        case .custom: return .purple
        }
    }
}

struct RiskMetricRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(6)
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
    
    return ValuationScenariosView(business: business)
        .modelContainer(for: [Business.self, ValuationScenario.self], inMemory: true)
}
