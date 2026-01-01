//
//  QuickValuationView.swift
//  Business Eval
//
//  Created by Scott Campbell on 1/1/26.
//
//  Allows quick valuation calculation for any business directly from the Valuations tab.
//

import SwiftUI
import SwiftData

struct QuickValuationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Business.name, order: .forward) private var businesses: [Business]
    
    // Selected business
    @State private var selectedBusiness: Business?
    
    // Valuation parameters
    @State private var methodology: ValuationMethodology = .profitMultiple
    @State private var multiple: Double = 3.0
    @State private var calculatedValue: Double = 0
    @State private var confidenceLevel: ConfidenceLevel = .medium
    @State private var notes = ""
    
    // Asset-based valuation inputs
    @State private var estimatedAssetValue: Double = 0
    @State private var estimatedBlueSkyValue: Double = 0
    
    // Industry standard multiples
    private let industryMultiples: [ValuationMethodology: Double] = [
        .revenueMultiple: 2.5,
        .profitMultiple: 3.0,
        .ebitdaMultiple: 6.0,
        .sdeMultiple: 3.5,
        .assetBased: 1.0,
        .discountedCashFlow: 1.0,
        .marketComparison: 1.0
    ]
    
    var body: some View {
        NavigationView {
            Form {
                // Business Selection Section
                Section {
                    if businesses.isEmpty {
                        Text("No businesses available")
                            .foregroundColor(AppTheme.Colors.secondary)
                    } else {
                        Picker("Select Business", selection: $selectedBusiness) {
                            Text("Choose a business...").tag(nil as Business?)
                            ForEach(businesses) { business in
                                BusinessPickerRow(business: business)
                                    .tag(business as Business?)
                            }
                        }
                        .onChange(of: selectedBusiness) { _, _ in
                            recalculate()
                        }
                    }
                } header: {
                    Text("Business")
                } footer: {
                    if let business = selectedBusiness {
                        Text("Revenue: \(formatCurrency(business.annualRevenue)) • Profit: \(formatCurrency(business.annualProfit))")
                    }
                }
                
                // Only show calculation options if a business is selected
                if let business = selectedBusiness {
                    // Methodology Section
                    Section {
                        Picker("Valuation Method", selection: $methodology) {
                            ForEach(ValuationMethodology.allCases, id: \.self) { method in
                                Text(method.rawValue).tag(method)
                            }
                        }
                        .onChange(of: methodology) { _, _ in
                            setIndustryMultiple()
                            recalculate()
                        }
                        
                        Text(methodologyDescription)
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                    } header: {
                        Text("Methodology")
                    }
                    
                    // Asset-Based Valuation Inputs (only show for asset-based methodology)
                    if methodology == .assetBased {
                        Section {
                            HStack {
                                Text("Estimated Asset Value")
                                Spacer()
                                TextField("Asset Value", value: $estimatedAssetValue, format: .currency(code: "USD").precision(.fractionLength(0)))
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 120)
                                    .multilineTextAlignment(.trailing)
                                    .onChange(of: estimatedAssetValue) { _, _ in
                                        recalculate()
                                    }
                            }
                            
                            HStack {
                                Text("Estimated Blue Sky Value")
                                Spacer()
                                TextField("Blue Sky", value: $estimatedBlueSkyValue, format: .currency(code: "USD").precision(.fractionLength(0)))
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 120)
                                    .multilineTextAlignment(.trailing)
                                    .onChange(of: estimatedBlueSkyValue) { _, _ in
                                        recalculate()
                                    }
                            }
                        } header: {
                            Text("Asset-Based Inputs")
                        } footer: {
                            Text("Asset Value = tangible assets (equipment, inventory, etc.). Blue Sky = intangible value (goodwill, brand, customer base).")
                        }
                    } else {
                        // Multiple Section (for non-asset-based methodologies)
                        Section {
                            HStack {
                                Text("Multiple")
                                Spacer()
                                TextField("Multiple", value: $multiple, format: .number.precision(.fractionLength(2)))
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 80)
                                    .multilineTextAlignment(.trailing)
                                    .onChange(of: multiple) { _, _ in
                                        recalculate()
                                    }
                            }
                            
                            Slider(value: $multiple, in: 0.5...15.0, step: 0.1)
                                .onChange(of: multiple) { _, _ in
                                    recalculate()
                                }
                            
                            HStack {
                                Text("Industry Standard")
                                    .font(AppTheme.Fonts.caption)
                                    .foregroundColor(AppTheme.Colors.secondary)
                                Spacer()
                                Button("\(industryMultiples[methodology, default: 1.0], specifier: "%.1f")x") {
                                    multiple = industryMultiples[methodology, default: 1.0]
                                    recalculate()
                                }
                                .font(AppTheme.Fonts.captionMedium)
                            }
                        } header: {
                            Text("Multiple")
                        }
                    }
                    
                    // Calculated Value Section
                    Section {
                        // Main valuation result
                        HStack {
                            Text("Calculated Value")
                                .font(AppTheme.Fonts.headline)
                            Spacer()
                            Text(formatCurrency(calculatedValue))
                                .font(AppTheme.Fonts.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.Colors.money)
                        }
                        
                        // Comparison to asking price
                        let difference = calculatedValue - business.askingPrice
                        let percentage = business.askingPrice > 0 ? (difference / business.askingPrice) * 100 : 0
                        
                        HStack {
                            Text("Asking Price")
                            Spacer()
                            Text(formatCurrency(business.askingPrice))
                                .foregroundColor(AppTheme.Colors.secondary)
                        }
                        
                        HStack {
                            Text("Difference")
                            Spacer()
                            Text("\(difference >= 0 ? "+" : "")\(formatCurrency(difference)) (\(String(format: "%.1f", percentage))%)")
                                .foregroundColor(difference >= 0 ? AppTheme.Colors.success : AppTheme.Colors.destructive)
                                .fontWeight(.medium)
                        }
                        
                        // Value assessment
                        valuationAssessment(difference: difference, percentage: percentage)
                    } header: {
                        Text("Valuation Result")
                    }
                    
                    // Confidence Level Section
                    Section {
                        Picker("Confidence Level", selection: $confidenceLevel) {
                            ForEach(ConfidenceLevel.allCases, id: \.self) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        confidenceDescription
                    } header: {
                        Text("Confidence")
                    }
                    
                    // Notes Section
                    Section("Notes") {
                        TextField("Add notes about this valuation...", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
            }
            .navigationTitle("Quick Valuation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveValuation()
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedBusiness == nil || calculatedValue <= 0)
                }
            }
            .onAppear {
                setIndustryMultiple()
            }
        }
    }
    
    // MARK: - Helper Views
    
    private var methodologyDescription: String {
        switch methodology {
        case .revenueMultiple:
            return "Annual Revenue × Multiple"
        case .profitMultiple:
            return "Annual Profit × Multiple"
        case .ebitdaMultiple:
            return "EBITDA × Multiple (using profit as proxy)"
        case .sdeMultiple:
            return "Seller's Discretionary Earnings × Multiple"
        case .assetBased:
            return "Estimated Asset Value + Blue Sky Value"
        case .discountedCashFlow:
            return "Based on projected cash flows"
        case .marketComparison:
            return "Based on comparable sales"
        }
    }
    
    private var confidenceDescription: some View {
        HStack {
            Image(systemName: confidenceIcon)
                .foregroundColor(confidenceColor)
            Text(confidenceText)
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.secondary)
        }
    }
    
    private var confidenceIcon: String {
        switch confidenceLevel {
        case .low: return "exclamationmark.triangle"
        case .medium: return "questionmark.circle"
        case .high: return "checkmark.circle"
        case .veryHigh: return "checkmark.seal.fill"
        }
    }
    
    private var confidenceColor: Color {
        switch confidenceLevel {
        case .low: return AppTheme.Colors.destructive
        case .medium: return AppTheme.Colors.warning
        case .high: return AppTheme.Colors.success
        case .veryHigh: return AppTheme.Colors.primary
        }
    }
    
    private var confidenceText: String {
        switch confidenceLevel {
        case .low: return "Limited data or high uncertainty"
        case .medium: return "Reasonable confidence with some assumptions"
        case .high: return "Strong confidence with good data support"
        case .veryHigh: return "Very high confidence with comprehensive data"
        }
    }
    
    private func valuationAssessment(difference: Double, percentage: Double) -> some View {
        HStack {
            Image(systemName: assessmentIcon(percentage: percentage))
                .foregroundColor(assessmentColor(percentage: percentage))
            Text(assessmentText(percentage: percentage))
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.secondary)
        }
        .padding(.vertical, AppTheme.Spacing.xs)
    }
    
    private func assessmentIcon(percentage: Double) -> String {
        if percentage < -20 {
            return "arrow.down.circle.fill"
        } else if percentage < -5 {
            return "arrow.down.right.circle"
        } else if percentage <= 5 {
            return "equal.circle"
        } else if percentage <= 20 {
            return "arrow.up.right.circle"
        } else {
            return "arrow.up.circle.fill"
        }
    }
    
    private func assessmentColor(percentage: Double) -> Color {
        if percentage < -20 {
            return AppTheme.Colors.destructive
        } else if percentage < -5 {
            return AppTheme.Colors.warning
        } else if percentage <= 5 {
            return AppTheme.Colors.secondary
        } else if percentage <= 20 {
            return AppTheme.Colors.success
        } else {
            return AppTheme.Colors.money
        }
    }
    
    private func assessmentText(percentage: Double) -> String {
        if percentage < -20 {
            return "Significantly overpriced based on this valuation"
        } else if percentage < -5 {
            return "Slightly overpriced - negotiate down"
        } else if percentage <= 5 {
            return "Fair price - close to calculated value"
        } else if percentage <= 20 {
            return "Good value - priced below valuation"
        } else {
            return "Excellent value - significantly underpriced"
        }
    }
    
    // MARK: - Calculation Logic
    
    private func setIndustryMultiple() {
        multiple = industryMultiples[methodology, default: 1.0]
    }
    
    private func recalculate() {
        guard let _ = selectedBusiness else {
            calculatedValue = 0
            return
        }
        
        switch methodology {
        case .revenueMultiple:
            calculatedValue = selectedBusiness!.annualRevenue * multiple
        case .profitMultiple, .ebitdaMultiple, .sdeMultiple:
            calculatedValue = selectedBusiness!.annualProfit * multiple
        case .assetBased:
            // Asset-based = Estimated Asset Value + Blue Sky Value
            calculatedValue = estimatedAssetValue + estimatedBlueSkyValue
        case .discountedCashFlow, .marketComparison:
            // Manual entry required - use asking price as starting point
            calculatedValue = selectedBusiness!.askingPrice * multiple
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        if amount >= 1_000_000 {
            return String(format: "$%.2fM", amount / 1_000_000)
        } else if amount >= 1_000 {
            return String(format: "$%.0fK", amount / 1_000)
        } else {
            return String(format: "$%.0f", amount)
        }
    }
    
    // MARK: - Save Valuation
    
    private func saveValuation() {
        guard let business = selectedBusiness else { return }
        
        let valuation = Valuation(
            calculatedValue: calculatedValue,
            multiple: multiple,
            methodology: methodology,
            confidenceLevel: confidenceLevel,
            business: business
        )
        
        if !notes.isEmpty {
            valuation.notes = notes
        }
        
        // Store specific multiples based on methodology
        switch methodology {
        case .revenueMultiple:
            valuation.revenueMultiple = multiple
        case .profitMultiple:
            valuation.profitMultiple = multiple
        case .ebitdaMultiple:
            valuation.ebitdaMultiple = multiple
        case .sdeMultiple:
            valuation.sdeMultiple = multiple
        default:
            break
        }
        
        business.valuations.append(valuation)
        modelContext.insert(valuation)
        dismiss()
    }
}

// MARK: - Business Picker Row
struct BusinessPickerRow: View {
    let business: Business
    
    var body: some View {
        HStack {
            Text(business.name)
            Spacer()
            if business.valuations.isEmpty {
                Text("No valuations")
                    .font(.caption2)
                    .foregroundColor(AppTheme.Colors.warning)
            } else {
                Text("\(business.valuations.count)")
                    .font(.caption2)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
        }
    }
}

#Preview {
    QuickValuationView()
        .modelContainer(for: [Business.self, Valuation.self], inMemory: true)
}
