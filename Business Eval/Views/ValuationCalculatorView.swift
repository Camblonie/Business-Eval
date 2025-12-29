//
//  ValuationCalculatorView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData

struct ValuationCalculatorView: View {
    let business: Business
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var methodology: ValuationMethodology = .revenueMultiple
    @State private var multiple: Double = 3.0
    @State private var calculatedValue: Double = 0
    @State private var confidenceLevel: ConfidenceLevel = .medium
    @State private var notes = ""
    @State private var isManualMode = false
    
    // Industry standard multiples (could be expanded or made configurable)
    private let industryMultiples: [ValuationMethodology: Double] = [
        .revenueMultiple: 2.5,
        .profitMultiple: 8.0,
        .ebitdaMultiple: 6.0,
        .sdeMultiple: 3.5
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Calculation Mode") {
                    Toggle("Manual Entry", isOn: $isManualMode)
                        .onChange(of: isManualMode) { _, newValue in
                            if !newValue {
                                calculateValuation()
                            }
                        }
                }
                
                Section("Methodology") {
                    Picker("Valuation Method", selection: $methodology) {
                        ForEach(ValuationMethodology.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .onChange(of: methodology) { _, _ in
                        if !isManualMode {
                            setIndustryMultiple()
                            calculateValuation()
                        }
                    }
                    
                    Text(methodologyDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !isManualMode {
                    Section("Business Metrics") {
                        businessMetricsSection
                    }
                    
                    Section("Industry Standard Multiple") {
                        HStack {
                            Text("Suggested Multiple")
                            Spacer()
                            Text("\(industryMultiples[methodology, default: 1.0], specifier: "%.2f")x")
                                .foregroundColor(.blue)
                        }
                        
                        Button("Use Industry Standard") {
                            multiple = industryMultiples[methodology, default: 1.0]
                            calculateValuation()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                Section("Multiple") {
                    HStack {
                        Text("Multiple")
                        Spacer()
                        TextField("Enter multiple", value: $multiple, format: .number.precision(.fractionLength(2)))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                            .onChange(of: multiple) { _, _ in
                                calculateValuation()
                            }
                    }
                    
                    if !isManualMode {
                        Slider(value: $multiple, in: 0.5...10.0, step: 0.1)
                            .onChange(of: multiple) { _, _ in
                                calculateValuation()
                            }
                    }
                }
                
                Section("Calculated Value") {
                    HStack {
                        Text("Valuation")
                        Spacer()
                        Text("$\(String(format: "%.0f", calculatedValue))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    let difference = calculatedValue - business.askingPrice
                    let percentage = business.askingPrice > 0 ? (difference / business.askingPrice) * 100 : 0
                    
                    HStack {
                        Text("vs Asking Price")
                        Spacer()
                        Text("\(difference >= 0 ? "+" : "")$\(String(format: "%.0f", difference)) (\(String(format: "%.1f", percentage))%)")
                            .foregroundColor(difference >= 0 ? .green : .red)
                    }
                }
                
                Section("Confidence Level") {
                    Picker("Confidence", selection: $confidenceLevel) {
                        ForEach(ConfidenceLevel.allCases, id: \.self) { confidence in
                            Text(confidence.rawValue).tag(confidence)
                        }
                    }
                    
                    confidenceDescription
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Valuation Calculator")
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
                        dismiss()
                    }
                    .disabled(calculatedValue <= 0)
                }
            }
        }
        .onAppear {
            setIndustryMultiple()
            calculateValuation()
        }
    }
    
    private var businessMetricsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch methodology {
            case .revenueMultiple:
                MetricRow(label: "Annual Revenue", value: "$\(business.annualRevenue, specifier: "%.0f")")
                
            case .profitMultiple:
                MetricRow(label: "Annual Profit", value: "$\(business.annualProfit, specifier: "%.0f")")
                
            case .ebitdaMultiple:
                MetricRow(label: "Annual Profit (EBITDA proxy)", value: "$\(business.annualProfit, specifier: "%.0f")")
                Text("Note: Using annual profit as EBITDA proxy")
                    .font(.caption)
                    .foregroundColor(.orange)
                
            case .sdeMultiple:
                MetricRow(label: "Annual Profit (SDE proxy)", value: "$\(business.annualProfit, specifier: "%.0f")")
                Text("Note: Using annual profit as SDE proxy")
                    .font(.caption)
                    .foregroundColor(.orange)
                
            case .assetBased, .discountedCashFlow, .marketComparison:
                Text("Manual calculation required for this methodology")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var methodologyDescription: String {
        switch methodology {
        case .revenueMultiple:
            return "Annual Revenue × Multiple"
        case .profitMultiple:
            return "Annual Profit × Multiple"
        case .ebitdaMultiple:
            return "EBITDA × Multiple"
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
    
    private var confidenceDescription: Text {
        switch confidenceLevel {
        case .low:
            return Text("Limited data or high uncertainty")
                .font(.caption)
                .foregroundColor(.red)
        case .medium:
            return Text("Reasonable confidence with some assumptions")
                .font(.caption)
                .foregroundColor(.orange)
        case .high:
            return Text("Strong confidence with good data support")
                .font(.caption)
                .foregroundColor(.green)
        case .veryHigh:
            return Text("Very high confidence with comprehensive data")
                .font(.caption)
                .foregroundColor(.blue)
        }
    }
    
    private func setIndustryMultiple() {
        multiple = industryMultiples[methodology, default: 1.0]
    }
    
    private func calculateValuation() {
        switch methodology {
        case .revenueMultiple:
            calculatedValue = business.annualRevenue * multiple
        case .profitMultiple:
            calculatedValue = business.annualProfit * multiple
        case .ebitdaMultiple:
            calculatedValue = business.annualProfit * multiple
        case .sdeMultiple:
            calculatedValue = business.annualProfit * multiple
        case .assetBased, .discountedCashFlow, .marketComparison:
            // For these methodologies, manual calculation is expected
            break
        }
    }
    
    private func saveValuation() {
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
        
        modelContext.insert(valuation)
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
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
    
    return ValuationCalculatorView(business: business)
        .modelContainer(for: [Business.self, Valuation.self], inMemory: true)
}
