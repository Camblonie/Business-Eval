//
//  AddScenarioView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI

struct AddScenarioView: View {
    let business: Business
    let onAdd: (ValuationScenario) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var scenarioType: ScenarioType = .custom
    @State private var baseValuation: Double = 0
    @State private var adjustedRevenue: Double = 0
    @State private var adjustedProfit: Double = 0
    @State private var growthRate: Double = 0
    @State private var riskAdjustment: Double = 0
    @State private var marketConditions: MarketConditions = .average
    @State private var assumptions: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Scenario Type") {
                    Picker("Type", selection: $scenarioType) {
                        ForEach(ScenarioType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Financial Adjustments") {
                    HStack {
                        Text("Base Valuation")
                        Spacer()
                        TextField("Value", value: $baseValuation, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                    }
                    
                    HStack {
                        Text("Adjusted Revenue")
                        Spacer()
                        TextField("Value", value: $adjustedRevenue, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                    }
                    
                    HStack {
                        Text("Adjusted Profit")
                        Spacer()
                        TextField("Value", value: $adjustedProfit, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                    }
                }
                
                Section("Growth & Risk") {
                    HStack {
                        Text("Growth Rate")
                        Spacer()
                        TextField("Rate", value: $growthRate, format: .percent)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                    }
                    
                    HStack {
                        Text("Risk Adjustment")
                        Spacer()
                        TextField("Risk", value: $riskAdjustment, format: .percent)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                    }
                    
                    Picker("Market Conditions", selection: $marketConditions) {
                        ForEach(MarketConditions.allCases, id: \.self) { condition in
                            Text(condition.rawValue).tag(condition)
                        }
                    }
                }
                
                Section("Notes") {
                    TextField("Assumptions", text: $assumptions, axis: .vertical)
                        .lineLimit(3)
                    
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .navigationTitle("Add Scenario")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let scenario = ValuationScenario(
                            business: business,
                            scenarioType: scenarioType,
                            baseValuation: baseValuation,
                            adjustedRevenue: adjustedRevenue,
                            adjustedProfit: adjustedProfit,
                            growthRate: growthRate,
                            riskAdjustment: riskAdjustment,
                            marketConditions: marketConditions,
                            assumptions: assumptions.isEmpty ? nil : assumptions,
                            notes: notes.isEmpty ? nil : notes
                        )
                        onAdd(scenario)
                        dismiss()
                    }
                    .disabled(baseValuation <= 0 || adjustedRevenue <= 0 || adjustedProfit <= 0)
                }
            }
            .onAppear {
                // Set default values
                baseValuation = business.askingPrice
                adjustedRevenue = business.annualRevenue
                adjustedProfit = business.annualProfit
                growthRate = 0.08
                riskAdjustment = 0.1
            }
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
    
    return AddScenarioView(business: business) { _ in }
}
