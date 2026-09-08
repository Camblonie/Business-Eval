//
//  ValuationDetailView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI

struct ValuationDetailView: View {
    @Bindable var valuation: Valuation
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditValuation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sectionSpacing) {
                // Business Information
                businessSection
                    .fadeIn(delay: 0)
                
                // Valuation Summary
                valuationSummarySection
                    .fadeIn(delay: 0.05)
                
                // Methodology Details
                methodologySection
                    .fadeIn(delay: 0.1)
                
                // Financial Metrics
                financialMetricsSection
                    .fadeIn(delay: 0.15)
                
                // Confidence Analysis
                confidenceSection
                    .fadeIn(delay: 0.2)
                
                // Notes
                if let notes = valuation.notes, !notes.isEmpty {
                    notesSection(notes: notes)
                        .fadeIn(delay: 0.25)
                }
            }
            .padding()
        }
        .navigationTitle("Valuation Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: { showingEditValuation = true }) {
                        Image(systemName: "pencil.circle")
                    }
                    
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditValuation) {
            EditValuationView(valuation: valuation)
        }
    }
    
    private var businessSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Business")
                .font(AppTheme.Fonts.headline)
            
            if let business = valuation.business {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    // Display the business name, falling back to the teaser if the name is empty
                    Text(business.displayName)
                        .font(AppTheme.Fonts.subheadlineMedium)
                    
                    Text(business.industry)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                    
                    HStack {
                        Text("Asking Price:")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        
                        Text(formatCurrency(business.askingPrice))
                            .font(AppTheme.Fonts.captionMedium)
                            .foregroundColor(AppTheme.Colors.money)
                        
                        Spacer()
                        
                        let difference = valuation.calculatedValue - business.askingPrice
                        let percentageDifference = (difference / business.askingPrice) * 100
                        
                        Text("\(difference >= 0 ? "+" : "")\(formatCurrency(abs(difference))) (\(String(format: "%.1f", percentageDifference))%)")
                            .font(AppTheme.Fonts.captionMedium)
                            .foregroundColor(difference >= 0 ? AppTheme.Colors.success : AppTheme.Colors.destructive)
                    }
                }
            } else {
                Text("Business information not available")
                    .font(AppTheme.Fonts.subheadline)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
        }
        .cardStyle()
    }
    
    /// Formats currency with K/M suffixes for large numbers
    private func formatCurrency(_ amount: Double) -> String {
        if amount >= 1_000_000 {
            return String(format: "$%.1fM", amount / 1_000_000)
        } else if amount >= 1_000 {
            return String(format: "$%.0fK", amount / 1_000)
        } else {
            return String(format: "$%.0f", amount)
        }
    }
    
    private var valuationSummarySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Valuation Summary")
                .font(AppTheme.Fonts.headline)
            
            // Key metric with visual emphasis
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("Calculated Value")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                    
                    Text(formatCurrency(valuation.calculatedValue))
                        .font(AppTheme.Fonts.largeTitle)
                        .foregroundColor(AppTheme.Colors.money)
                }
                
                Spacer()
                
                // Confidence indicator
                VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                    Text("Confidence")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                    
                    ConfidenceBadge(valuation.confidenceLevel)
                }
            }
            
            ThemedDivider()
            
            // Secondary metrics in grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.sm) {
                ThemedMetricCard(
                    title: "Multiple",
                    value: String(format: "%.2fx", valuation.multiple),
                    icon: "multiply.circle.fill",
                    color: AppTheme.Colors.primary
                )
                
                ThemedMetricCard(
                    title: "Date",
                    value: valuation.createdAt.formatted(date: .abbreviated, time: .omitted),
                    icon: "calendar",
                    color: AppTheme.Colors.info
                )
            }
        }
        .elevatedCardStyle()
    }
    
    private var methodologySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Methodology")
                .font(AppTheme.Fonts.headline)
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text(valuation.methodology.rawValue)
                    .font(AppTheme.Fonts.subheadlineMedium)
                
                Text(methodologyDescription)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
        }
        .cardStyle()
    }
    
    private var financialMetricsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Financial Metrics")
                .font(AppTheme.Fonts.headline)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                if let revenueMultiple = valuation.revenueMultiple {
                    ValuationMetricRow(label: "Revenue Multiple", value: "\(String(format: "%.2f", revenueMultiple))x")
                }
                
                if let profitMultiple = valuation.profitMultiple {
                    ValuationMetricRow(label: "Profit Multiple", value: "\(String(format: "%.2f", profitMultiple))x")
                }
                
                if let ebitdaMultiple = valuation.ebitdaMultiple {
                    ValuationMetricRow(label: "EBITDA Multiple", value: "\(String(format: "%.2f", ebitdaMultiple))x")
                }
                
                if let sdeMultiple = valuation.sdeMultiple {
                    ValuationMetricRow(label: "SDE Multiple", value: "\(String(format: "%.2f", sdeMultiple))x")
                }
                
                if valuation.revenueMultiple == nil && valuation.profitMultiple == nil && 
                   valuation.ebitdaMultiple == nil && valuation.sdeMultiple == nil {
                    Text("No detailed financial metrics recorded")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                }
            }
            
            // Debt Service Coverage Ratio calculation
            // Uses same assumptions as business financing: 9% interest, 10 year term, 10% down payment
            if let business = valuation.business, business.annualProfit > 0, valuation.calculatedValue > 0 {
                ThemedDivider()
                
                Text("Financing Analysis")
                    .font(AppTheme.Fonts.subheadline)
                    .foregroundColor(AppTheme.Colors.secondary)
                
                // Financing parameters
                let downPaymentPercent = 10.0
                let loanInterestRate = 9.0
                let loanTermYears = 10
                
                // Calculate loan details
                let downPaymentAmount = valuation.calculatedValue * (downPaymentPercent / 100.0)
                let loanAmount = valuation.calculatedValue - downPaymentAmount
                
                // Calculate annual loan payment using amortization formula
                let annualLoanPayment: Double = {
                    guard loanAmount > 0, loanInterestRate > 0, loanTermYears > 0 else {
                        return 0
                    }
                    
                    let monthlyRate = (loanInterestRate / 100.0) / 12.0
                    let numberOfPayments = Double(loanTermYears * 12)
                    
                    let numerator = monthlyRate * pow(1 + monthlyRate, numberOfPayments)
                    let denominator = pow(1 + monthlyRate, numberOfPayments) - 1
                    
                    let monthlyPayment = loanAmount * (numerator / denominator)
                    
                    return monthlyPayment * 12.0
                }()
                
                // Calculate DSCR
                if annualLoanPayment > 0 {
                    let dscr = business.annualProfit / annualLoanPayment
                    
                    VStack(spacing: AppTheme.Spacing.xs) {
                        HStack {
                            Text("Down Payment")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Spacer()
                            Text("\(Int(downPaymentPercent))% (\(formatCurrency(downPaymentAmount)))")
                                .font(AppTheme.Fonts.captionMedium)
                        }
                        
                        HStack {
                            Text("Loan Amount")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Spacer()
                            Text(formatCurrency(loanAmount))
                                .font(AppTheme.Fonts.captionMedium)
                        }
                        
                        HStack {
                            Text("Interest Rate")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Spacer()
                            Text(String(format: "%.2f%%", loanInterestRate))
                                .font(AppTheme.Fonts.captionMedium)
                        }
                        
                        HStack {
                            Text("Loan Term")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Spacer()
                            Text("\(loanTermYears) years")
                                .font(AppTheme.Fonts.captionMedium)
                        }
                        
                        HStack {
                            Text("Annual Loan Payment")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Spacer()
                            Text(formatCurrency(annualLoanPayment))
                                .font(AppTheme.Fonts.captionMedium)
                        }
                        
                        ThemedDivider()
                        
                        HStack {
                            Text("Debt Service Coverage Ratio")
                                .font(AppTheme.Fonts.captionMedium)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Spacer()
                            Text(String(format: "%.2f", dscr))
                                .font(AppTheme.Fonts.subheadlineMedium)
                                .foregroundColor(dscr >= 1.5 ? AppTheme.Colors.success : (dscr >= 1.25 ? AppTheme.Colors.warning : AppTheme.Colors.destructive))
                        }
                    }
                    .padding(AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(AppTheme.CornerRadius.medium)
                }
            }
        }
        .cardStyle()
    }
    
    private var confidenceSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Confidence Level")
                .font(AppTheme.Fonts.headline)
            
            HStack {
                ConfidenceBadge(valuation.confidenceLevel)
                
                Spacer()
                
                ConfidenceIndicator(level: valuation.confidenceLevel)
            }
            
            Text(confidenceDescription)
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.secondary)
        }
        .cardStyle()
    }
    
    private func notesSection(notes: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Notes")
                .font(AppTheme.Fonts.headline)
            
            Text(notes)
                .font(AppTheme.Fonts.body)
        }
        .cardStyle()
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
    
}

struct ValuationMetricRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.secondary)
            
            Spacer()
            
            Text(value)
                .font(AppTheme.Fonts.captionMedium)
        }
    }
}

struct ConfidenceIndicator: View {
    let level: ConfidenceLevel
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            ForEach(1...4, id: \.self) { index in
                Circle()
                    .fill(index <= confidenceLevelValue ? AppTheme.Colors.confidenceColor(for: level) : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
    
    private var confidenceLevelValue: Int {
        switch level {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        case .veryHigh: return 4
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
