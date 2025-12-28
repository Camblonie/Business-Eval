//
//  ValuationDetailView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI

struct ValuationDetailView: View {
    let valuation: Valuation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Business Information
                businessSection
                
                // Valuation Summary
                valuationSummarySection
                
                // Methodology Details
                methodologySection
                
                // Financial Metrics
                financialMetricsSection
                
                // Confidence Analysis
                confidenceSection
                
                // Notes
                if let notes = valuation.notes, !notes.isEmpty {
                    notesSection(notes: notes)
                }
            }
            .padding()
        }
        .navigationTitle("Valuation Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private var businessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Business")
                .font(.headline)
                .fontWeight(.bold)
            
            if let business = valuation.business {
                VStack(alignment: .leading, spacing: 8) {
                    Text(business.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(business.industry)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Asking Price:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("$\(business.askingPrice, specifier: "%.0f")")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        let difference = valuation.calculatedValue - business.askingPrice
                        let percentageDifference = (difference / business.askingPrice) * 100
                        
                        Text("\(difference >= 0 ? "+" : "")$\(difference, specifier: "%.0f") (\(String(format: "%.1f", percentageDifference))%)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(difference >= 0 ? .green : .red)
                    }
                }
            } else {
                Text("Business information not available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var valuationSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Valuation Summary")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Calculated Value:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("$\(valuation.calculatedValue, specifier: "%.0f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Multiple:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(valuation.multiple, specifier: "%.2f")x")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Date:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(valuation.createdAt, style: .date)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var methodologySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Methodology")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(valuation.methodology.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(methodologyDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var financialMetricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Financial Metrics")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                if let revenueMultiple = valuation.revenueMultiple {
                    MetricRow(label: "Revenue Multiple", value: "\(revenueMultiple, specifier: "%.2f")x")
                }
                
                if let profitMultiple = valuation.profitMultiple {
                    MetricRow(label: "Profit Multiple", value: "\(profitMultiple, specifier: "%.2f")x")
                }
                
                if let ebitdaMultiple = valuation.ebitdaMultiple {
                    MetricRow(label: "EBITDA Multiple", value: "\(ebitdaMultiple, specifier: "%.2f")x")
                }
                
                if let sdeMultiple = valuation.sdeMultiple {
                    MetricRow(label: "SDE Multiple", value: "\(sdeMultiple, specifier: "%.2f")x")
                }
                
                if valuation.revenueMultiple == nil && valuation.profitMultiple == nil && 
                   valuation.ebitdaMultiple == nil && valuation.sdeMultiple == nil {
                    Text("No detailed financial metrics recorded")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var confidenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Confidence Level")
                .font(.headline)
                .fontWeight(.bold)
            
            HStack {
                Text(valuation.confidenceLevel.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(confidenceColor.opacity(0.2))
                    .foregroundColor(confidenceColor)
                    .cornerRadius(8)
                
                Spacer()
                
                ConfidenceIndicator(level: valuation.confidenceLevel)
            }
            
            Text(confidenceDescription)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func notesSection(notes: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
                .fontWeight(.bold)
            
            Text(notes)
                .font(.body)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // Computed properties
    private var methodologyDescription: String {
        switch valuation.methodology {
        case .revenueMultiple:
            return "Valuation based on a multiple of annual revenue"
        case .profitMultiple:
            return "Valuation based on a multiple of annual profit"
        case .ebitdaMultiple:
            return "Valuation based on a multiple of EBITDA (Earnings Before Interest, Taxes, Depreciation, and Amortization)"
        case .sdeMultiple:
            return "Valuation based on a multiple of SDE (Seller's Discretionary Earnings)"
        case .assetBased:
            return "Valuation based on the fair market value of business assets"
        case .discountedCashFlow:
            return "Valuation based on projected future cash flows discounted to present value"
        case .marketComparison:
            return "Valuation based on comparable business sales in the market"
        }
    }
    
    private var confidenceDescription: String {
        switch valuation.confidenceLevel {
        case .low:
            return "Limited data or high uncertainty in valuation"
        case .medium:
            return "Reasonable confidence with some assumptions"
        case .high:
            return "Strong confidence with good data support"
        case .veryHigh:
            return "Very high confidence with comprehensive data"
        }
    }
    
    private var confidenceColor: Color {
        switch valuation.confidenceLevel {
        case .low:
            return .red
        case .medium:
            return .orange
        case .high:
            return .green
        case .veryHigh:
            return .blue
        }
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct ConfidenceIndicator: View {
    let level: ConfidenceLevel
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...4, id: \.self) { index in
                Circle()
                    .fill(index <= confidenceLevel ? confidenceColor : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
    
    private var confidenceLevel: Int {
        switch level {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        case .veryHigh: return 4
        }
    }
    
    private var confidenceColor: Color {
        switch level {
        case .low: return .red
        case .medium: return .orange
        case .high: return .green
        case .veryHigh: return .blue
        }
    }
}

#Preview {
    let valuation = Valuation(
        calculatedValue: 750000,
        multiple: 3.5,
        methodology: .revenueMultiple,
        confidenceLevel: .high
    )
    
    return ValuationDetailView(valuation: valuation)
}
