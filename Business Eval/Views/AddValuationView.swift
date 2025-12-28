//
//  AddValuationView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData

struct AddValuationView: View {
    let business: Business
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var calculatedValue = ""
    @State private var multiple = ""
    @State private var methodology: ValuationMethodology = .revenueMultiple
    @State private var confidenceLevel: ConfidenceLevel = .medium
    @State private var notes = ""
    
    private var isFormValid: Bool {
        Double(calculatedValue) != nil && Double(multiple) != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Valuation Details") {
                    TextField("Calculated Value", text: $calculatedValue)
                        .keyboardType(.decimalPad)
                    
                    TextField("Multiple", text: $multiple)
                        .keyboardType(.decimalPad)
                    
                    Picker("Methodology", selection: $methodology) {
                        ForEach(ValuationMethodology.allCases, id: \.self) { methodology in
                            Text(methodology.rawValue).tag(methodology)
                        }
                    }
                    
                    Picker("Confidence Level", selection: $confidenceLevel) {
                        ForEach(ConfidenceLevel.allCases, id: \.self) { confidence in
                            Text(confidence.rawValue).tag(confidence)
                        }
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section("Business") {
                    Text(business.name)
                        .foregroundColor(.secondary)
                    
                    Text("Asking Price: $\(business.askingPrice, specifier: "%.0f")")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add Valuation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        addValuation()
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private func addValuation() {
        let valuation = Valuation(
            calculatedValue: Double(calculatedValue) ?? 0,
            multiple: Double(multiple) ?? 0,
            methodology: methodology,
            confidenceLevel: confidenceLevel,
            business: business
        )
        
        if !notes.isEmpty {
            valuation.notes = notes
        }
        
        modelContext.insert(valuation)
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
    
    return AddValuationView(business: business)
        .modelContainer(for: [Business.self, Valuation.self], inMemory: true)
}
