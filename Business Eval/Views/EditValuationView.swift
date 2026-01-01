//
//  EditValuationView.swift
//  Business Eval
//
//  Created by Scott Campbell on 1/1/26.
//
//  Allows editing and recalculating an existing valuation based on current business data.
//

import SwiftUI
import SwiftData

struct EditValuationView: View {
    @Bindable var valuation: Valuation
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Valuation parameters
    @State private var methodology: ValuationMethodology
    @State private var multiple: Double
    @State private var calculatedValue: Double
    @State private var confidenceLevel: ConfidenceLevel
    @State private var notes: String
    
    // Track if values have changed
    @State private var hasChanges = false
    
    // Industry standard multiples
    private let industryMultiples: [ValuationMethodology: Double] = [
        .revenueMultiple: 2.5,
        .profitMultiple: 8.0,
        .ebitdaMultiple: 6.0,
        .sdeMultiple: 3.5,
        .assetBased: 1.0,
        .discountedCashFlow: 1.0,
        .marketComparison: 1.0
    ]
    
    init(valuation: Valuation) {
        self.valuation = valuation
        _methodology = State(initialValue: valuation.methodology)
        _multiple = State(initialValue: valuation.multiple)
        _calculatedValue = State(initialValue: valuation.calculatedValue)
        _confidenceLevel = State(initialValue: valuation.confidenceLevel)
        _notes = State(initialValue: valuation.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Business Info Section - shows current vs original data
                if let business = valuation.business {
                    businessDataSection(business)
                }
                
                // Methodology Section
                Section {
                    Picker("Valuation Method", selection: $methodology) {
                        ForEach(ValuationMethodology.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .onChange(of: methodology) { _, _ in
                        recalculate()
                        hasChanges = true
                    }
                    
                    Text(methodologyDescription)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                } header: {
                    Text("Methodology")
                }
                
                // Multiple Section
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
                                hasChanges = true
                            }
                    }
                    
                    Slider(value: $multiple, in: 0.5...15.0, step: 0.1)
                        .onChange(of: multiple) { _, _ in
                            recalculate()
                            hasChanges = true
                        }
                    
                    HStack {
                        Text("Industry Standard")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        Spacer()
                        Button("\(industryMultiples[methodology, default: 1.0], specifier: "%.1f")x") {
                            multiple = industryMultiples[methodology, default: 1.0]
                            recalculate()
                            hasChanges = true
                        }
                        .font(AppTheme.Fonts.captionMedium)
                    }
                    
                    // Original multiple for reference
                    HStack {
                        Text("Original Multiple")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        Spacer()
                        Text("\(valuation.multiple, specifier: "%.2f")x")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                    }
                } header: {
                    Text("Multiple")
                }
                
                // Calculated Value Section
                valuationResultSection
                
                // Confidence Level Section
                Section {
                    Picker("Confidence Level", selection: $confidenceLevel) {
                        ForEach(ConfidenceLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: confidenceLevel) { _, _ in
                        hasChanges = true
                    }
                    
                    confidenceDescription
                } header: {
                    Text("Confidence")
                }
                
                // Notes Section
                Section("Notes") {
                    TextField("Add notes about this valuation...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .onChange(of: notes) { _, _ in
                            hasChanges = true
                        }
                }
                
                // Quick Actions
                Section {
                    Button(action: recalculateWithCurrentData) {
                        Label("Recalculate with Current Business Data", systemImage: "arrow.clockwise")
                    }
                    
                    Button(action: resetToOriginal) {
                        Label("Reset to Original Values", systemImage: "arrow.uturn.backward")
                    }
                    .foregroundColor(AppTheme.Colors.warning)
                }
            }
            .navigationTitle("Edit Valuation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .disabled(!hasChanges)
                }
            }
        }
    }
    
    // MARK: - Business Data Section
    private func businessDataSection(_ business: Business) -> some View {
        Section {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text(business.name)
                    .font(AppTheme.Fonts.headline)
                
                // Show current business metrics
                HStack {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text("Current Revenue")
                            .font(.caption2)
                            .foregroundColor(AppTheme.Colors.secondary)
                        Text(formatCurrency(business.annualRevenue))
                            .font(AppTheme.Fonts.captionMedium)
                            .foregroundColor(AppTheme.Colors.money)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                        Text("Current Profit")
                            .font(.caption2)
                            .foregroundColor(AppTheme.Colors.secondary)
                        Text(formatCurrency(business.annualProfit))
                            .font(AppTheme.Fonts.captionMedium)
                            .foregroundColor(AppTheme.Colors.money)
                    }
                }
                
                ThemedDivider()
                
                HStack {
                    Text("Asking Price")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                    Spacer()
                    Text(formatCurrency(business.askingPrice))
                        .font(AppTheme.Fonts.captionMedium)
                }
            }
        } header: {
            Text("Business Data")
        } footer: {
            Text("Valuation created on \(valuation.createdAt.formatted(date: .abbreviated, time: .shortened))")
        }
    }
    
    // MARK: - Valuation Result Section
    private var valuationResultSection: some View {
        Section {
            // New calculated value
            HStack {
                Text("New Value")
                    .font(AppTheme.Fonts.headline)
                Spacer()
                Text(formatCurrency(calculatedValue))
                    .font(AppTheme.Fonts.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.Colors.money)
            }
            
            // Original value for comparison
            HStack {
                Text("Original Value")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
                Spacer()
                Text(formatCurrency(valuation.calculatedValue))
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
            
            // Change from original
            let change = calculatedValue - valuation.calculatedValue
            let changePercent = valuation.calculatedValue > 0 ? (change / valuation.calculatedValue) * 100 : 0
            
            if abs(change) > 0.01 {
                HStack {
                    Text("Change")
                        .font(AppTheme.Fonts.caption)
                    Spacer()
                    Text("\(change >= 0 ? "+" : "")\(formatCurrency(change)) (\(String(format: "%.1f", changePercent))%)")
                        .font(AppTheme.Fonts.captionMedium)
                        .foregroundColor(change >= 0 ? AppTheme.Colors.success : AppTheme.Colors.destructive)
                }
            }
            
            // Comparison to asking price
            if let business = valuation.business {
                ThemedDivider()
                
                let difference = calculatedValue - business.askingPrice
                let percentage = business.askingPrice > 0 ? (difference / business.askingPrice) * 100 : 0
                
                HStack {
                    Text("vs Asking Price")
                        .font(AppTheme.Fonts.caption)
                    Spacer()
                    Text("\(difference >= 0 ? "+" : "")\(formatCurrency(difference)) (\(String(format: "%.1f", percentage))%)")
                        .foregroundColor(difference >= 0 ? AppTheme.Colors.success : AppTheme.Colors.destructive)
                        .font(AppTheme.Fonts.captionMedium)
                }
                
                // Assessment
                valuationAssessment(percentage: percentage)
            }
        } header: {
            Text("Valuation Result")
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
            return "Based on business asset values"
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
    
    private func valuationAssessment(percentage: Double) -> some View {
        HStack {
            Image(systemName: assessmentIcon(percentage: percentage))
                .foregroundColor(assessmentColor(percentage: percentage))
            Text(assessmentText(percentage: percentage))
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.secondary)
        }
    }
    
    private func assessmentIcon(percentage: Double) -> String {
        if percentage < -20 { return "arrow.down.circle.fill" }
        else if percentage < -5 { return "arrow.down.right.circle" }
        else if percentage <= 5 { return "equal.circle" }
        else if percentage <= 20 { return "arrow.up.right.circle" }
        else { return "arrow.up.circle.fill" }
    }
    
    private func assessmentColor(percentage: Double) -> Color {
        if percentage < -20 { return AppTheme.Colors.destructive }
        else if percentage < -5 { return AppTheme.Colors.warning }
        else if percentage <= 5 { return AppTheme.Colors.secondary }
        else if percentage <= 20 { return AppTheme.Colors.success }
        else { return AppTheme.Colors.money }
    }
    
    private func assessmentText(percentage: Double) -> String {
        if percentage < -20 { return "Significantly overpriced" }
        else if percentage < -5 { return "Slightly overpriced" }
        else if percentage <= 5 { return "Fair price" }
        else if percentage <= 20 { return "Good value" }
        else { return "Excellent value" }
    }
    
    // MARK: - Calculation Logic
    
    private func recalculate() {
        guard let business = valuation.business else { return }
        
        switch methodology {
        case .revenueMultiple:
            calculatedValue = business.annualRevenue * multiple
        case .profitMultiple, .ebitdaMultiple, .sdeMultiple:
            calculatedValue = business.annualProfit * multiple
        case .assetBased, .discountedCashFlow, .marketComparison:
            calculatedValue = business.askingPrice * multiple
        }
    }
    
    private func recalculateWithCurrentData() {
        recalculate()
        hasChanges = true
    }
    
    private func resetToOriginal() {
        methodology = valuation.methodology
        multiple = valuation.multiple
        calculatedValue = valuation.calculatedValue
        confidenceLevel = valuation.confidenceLevel
        notes = valuation.notes ?? ""
        hasChanges = false
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
    
    // MARK: - Save Changes
    
    private func saveChanges() {
        valuation.methodology = methodology
        valuation.multiple = multiple
        valuation.calculatedValue = calculatedValue
        valuation.confidenceLevel = confidenceLevel
        valuation.notes = notes.isEmpty ? nil : notes
        
        // Update specific multiples based on methodology
        valuation.revenueMultiple = nil
        valuation.profitMultiple = nil
        valuation.ebitdaMultiple = nil
        valuation.sdeMultiple = nil
        
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
        
        dismiss()
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
        businessDescription: "A test business"
    )
    
    let valuation = Valuation(
        calculatedValue: 750000,
        multiple: 3.5,
        methodology: .revenueMultiple,
        confidenceLevel: .high,
        business: business
    )
    
    return EditValuationView(valuation: valuation)
        .modelContainer(for: [Business.self, Valuation.self], inMemory: true)
}
