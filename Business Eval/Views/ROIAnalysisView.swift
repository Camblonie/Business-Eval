//
//  ROIAnalysisView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData
import Charts

struct ROIAnalysisView: View {
    let business: Business
    @State private var purchasePrice: Double = 0
    @State private var investmentPeriod: Int = 5
    @State private var revenueGrowthRate: Double = 0.08
    @State private var profitMargin: Double = 0.2
    @State private var exitMultiple: Double = 3.0
    @State private var additionalInvestment: Double = 0
    @State private var workingCapital: Double = 50000
    @State private var roiResults: ROIResults?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Input Parameters
                inputParametersSection()
                
                // ROI Results
                if let results = roiResults {
                    roiResultsSection(results: results)
                    
                    // Cash Flow Analysis
                    cashFlowSection(results: results)
                    
                    // Sensitivity Analysis
                    sensitivityAnalysisSection(results: results)
                    
                    // Investment Metrics
                    investmentMetricsSection(results: results)
                    
                    // Risk Assessment
                    riskAssessmentSection(results: results)
                }
            }
            .padding()
        }
        .navigationTitle("ROI Analysis")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            purchasePrice = business.askingPrice
            profitMargin = business.annualRevenue > 0 ? business.annualProfit / business.annualRevenue : 0.2
            calculateROI()
        }
    }
    
    private func inputParametersSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Investment Parameters")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                InputRow(
                    title: "Purchase Price",
                    value: $purchasePrice,
                    formatType: .currency,
                    keyboardType: .decimalPad
                )
                
                InputRow(
                    title: "Investment Period",
                    value: Binding(
                        get: { Double(investmentPeriod) },
                        set: { investmentPeriod = Int($0) }
                    ),
                    formatType: .number,
                    keyboardType: .numberPad
                )
                
                InputRow(
                    title: "Revenue Growth Rate",
                    value: $revenueGrowthRate,
                    formatType: .percent,
                    keyboardType: .decimalPad
                )
                
                InputRow(
                    title: "Target Profit Margin",
                    value: $profitMargin,
                    formatType: .percent,
                    keyboardType: .decimalPad
                )
                
                InputRow(
                    title: "Exit Multiple",
                    value: $exitMultiple,
                    formatType: .number,
                    keyboardType: .decimalPad
                )
                
                InputRow(
                    title: "Additional Investment",
                    value: $additionalInvestment,
                    formatType: .currency,
                    keyboardType: .decimalPad
                )
                
                InputRow(
                    title: "Working Capital",
                    value: $workingCapital,
                    formatType: .currency,
                    keyboardType: .decimalPad
                )
                
                Button("Calculate ROI") {
                    calculateROI()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func roiResultsSection(results: ROIResults) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ROI Results")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ResultCard(
                    title: "Total ROI",
                    value: "\(String(format: "%.1f", results.totalROI * 100))%",
                    subtitle: "Over \(investmentPeriod) years",
                    color: results.totalROI > 0.2 ? .green : results.totalROI > 0 ? .orange : .red
                )
                
                ResultCard(
                    title: "Annual ROI",
                    value: "\(String(format: "%.1f", results.annualROI * 100))%",
                    subtitle: "Average per year",
                    color: results.annualROI > 0.15 ? .green : results.annualROI > 0 ? .orange : .red
                )
                
                ResultCard(
                    title: "Net Profit",
                    value: "$\(String(format: "%.0f", results.netProfit))",
                    subtitle: "Total profit after exit",
                    color: results.netProfit > 0 ? .green : .red
                )
                
                ResultCard(
                    title: "Payback Period",
                    value: "\(String(format: "%.1f", results.paybackPeriod)) years",
                    subtitle: "Time to recover investment",
                    color: results.paybackPeriod < 3 ? .green : results.paybackPeriod < 5 ? .orange : .red
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func cashFlowSection(results: ROIResults) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cash Flow Analysis")
                .font(.headline)
                .fontWeight(.bold)
            
            Chart {
                ForEach(Array(results.yearlyCashFlows.enumerated()), id: \.offset) { index, cashFlow in
                    BarMark(
                        x: .value("Year", "Year \(index + 1)"),
                        y: .value("Cash Flow", cashFlow)
                    )
                    .foregroundStyle(cashFlow >= 0 ? Color.green : Color.red)
                    .opacity(0.8)
                }
                
                // Cumulative cash flow line
                ForEach(Array(results.cumulativeCashFlows.enumerated()), id: \.offset) { index, cumulative in
                    LineMark(
                        x: .value("Year", "Year \(index + 1)"),
                        y: .value("Cumulative", cumulative)
                    )
                    .foregroundStyle(Color.blue)
                    .symbol(Circle().strokeBorder(lineWidth: 2))
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
            .chartLegend(position: .bottom) {
                HStack {
                    Label("Annual Cash Flow", systemImage: "rectangle.fill")
                        .foregroundColor(.green)
                    Label("Cumulative", systemImage: "line.diagonal")
                        .foregroundColor(.blue)
                }
                .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func sensitivityAnalysisSection(results: ROIResults) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sensitivity Analysis")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                SensitivityRow(
                    title: "Revenue Growth Impact",
                    baseValue: results.totalROI,
                    lowValue: results.lowGrowthROI,
                    highValue: results.highGrowthROI,
                    format: .percent
                )
                
                SensitivityRow(
                    title: "Profit Margin Impact",
                    baseValue: results.totalROI,
                    lowValue: results.lowMarginROI,
                    highValue: results.highMarginROI,
                    format: .percent
                )
                
                SensitivityRow(
                    title: "Exit Multiple Impact",
                    baseValue: results.totalROI,
                    lowValue: results.lowExitROI,
                    highValue: results.highExitROI,
                    format: .percent
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func investmentMetricsSection(results: ROIResults) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Investment Metrics")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                ROIMetricRow(
                    title: "Initial Investment",
                    value: "$\(String(format: "%.0f", results.totalInvestment))"
                )
                
                ROIMetricRow(
                    title: "Exit Value",
                    value: "$\(String(format: "%.0f", results.exitValue))"
                )
                
                ROIMetricRow(
                    title: "Total Cash Flow",
                    value: "$\(String(format: "%.0f", results.totalCashFlow))"
                )
                
                ROIMetricRow(
                    title: "IRR (Internal Rate of Return)",
                    value: "\(String(format: "%.1f", results.irr * 100))%"
                )
                
                ROIMetricRow(
                    title: "NPV (Net Present Value)",
                    value: "$\(String(format: "%.0f", results.npv))"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func riskAssessmentSection(results: ROIResults) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Risk Assessment")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                RiskAssessmentCard(
                    title: "Investment Risk",
                    level: results.investmentRisk,
                    description: results.riskDescription
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Key Risk Factors")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ForEach(results.riskFactors, id: \.self) { factor in
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
    
    // Helper functions
    private func calculateROI() {
        let calculator = ROICalculator()
        roiResults = calculator.calculateROI(
            business: business,
            purchasePrice: purchasePrice,
            investmentPeriod: investmentPeriod,
            revenueGrowthRate: revenueGrowthRate,
            profitMargin: profitMargin,
            exitMultiple: exitMultiple,
            additionalInvestment: additionalInvestment,
            workingCapital: workingCapital
        )
    }
}

struct InputRow: View {
    let title: String
    @Binding var value: Double
    let formatType: FormatType
    let keyboardType: UIKeyboardType
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            TextField("", value: $value, format: formatType.formatter)
                .keyboardType(keyboardType)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 120)
                .multilineTextAlignment(.trailing)
        }
    }
}

enum FormatType {
    case currency
    case number
    case percent
    
    var formatter: Format {
        switch self {
        case .currency:
            return .currency(code: "USD")
        case .number:
            return .number
        case .percent:
            return .percent.precision(.fractionLength(1))
        }
    }
}

struct ResultCard: View {
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

struct SensitivityRow: View {
    let title: String
    let baseValue: Double
    let lowValue: Double
    let highValue: Double
    let format: FormatType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                VStack {
                    Text("Low")
                        .font(.caption2)
                        .foregroundColor(.red)
                    Text(lowValue, format: format.formatter)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("Base")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text(baseValue, format: format.formatter)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("High")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Text(highValue, format: format)
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct ROIMetricRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct RiskAssessmentCard: View {
    let title: String
    let level: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(level)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(riskColor(level).opacity(0.2))
                    .foregroundColor(riskColor(level))
                    .cornerRadius(6)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    private func riskColor(_ level: String) -> Color {
        switch level {
        case "Low": return .green
        case "Medium": return .orange
        case "High": return .red
        default: return .gray
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
    
    return ROIAnalysisView(business: business)
}
