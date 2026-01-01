//
//  EditFinancialSummaryView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/30/25.
//

import SwiftUI
import SwiftData

struct EditFinancialSummaryView: View {
    @Bindable var business: Business
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Form state variables
    @State private var askingPrice: String
    @State private var annualRevenue: String
    @State private var annualProfit: String
    
    init(business: Business) {
        self.business = business
        // Initialize with current business values
        self._askingPrice = State(initialValue: business.askingPrice == 0 ? "" : String(business.askingPrice))
        self._annualRevenue = State(initialValue: business.annualRevenue == 0 ? "" : String(business.annualRevenue))
        self._annualProfit = State(initialValue: business.annualProfit == 0 ? "" : String(business.annualProfit))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Financial Information")) {
                    // Asking Price Field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Asking Price")
                            .font(.headline)
                        
                        HStack {
                            Text("$")
                                .foregroundColor(.secondary)
                            TextField("0", text: $askingPrice)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Annual Revenue Field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Annual Revenue")
                            .font(.headline)
                        
                        HStack {
                            Text("$")
                                .foregroundColor(.secondary)
                            TextField("0", text: $annualRevenue)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Annual Profit Field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Annual Profit")
                            .font(.headline)
                        
                        HStack {
                            Text("$")
                                .foregroundColor(.secondary)
                            TextField("0", text: $annualProfit)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Preview Section
                if !askingPrice.isEmpty || !annualRevenue.isEmpty || !annualProfit.isEmpty {
                    Section(header: Text("Preview")) {
                        VStack(spacing: 8) {
                            if !askingPrice.isEmpty {
                                FinancialRow(label: "Asking Price", value: Double(askingPrice) ?? 0, color: .green)
                            }
                            
                            if !annualRevenue.isEmpty {
                                FinancialRow(label: "Annual Revenue", value: Double(annualRevenue) ?? 0, color: .blue)
                            }
                            
                            if !annualProfit.isEmpty {
                                FinancialRow(label: "Annual Profit", value: Double(annualProfit) ?? 0, color: .purple)
                            }
                            
                            // Calculate and show profit margin if both revenue and profit are provided
                            if !annualRevenue.isEmpty && !annualProfit.isEmpty,
                               let revenue = Double(annualRevenue), revenue > 0,
                               let profit = Double(annualProfit) {
                                let profitMargin = (profit / revenue) * 100
                                FinancialRow(label: "Profit Margin", value: profitMargin, color: .orange, isPercentage: true)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Financial Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveFinancialData()
                        dismiss()
                    }
                    .disabled(!isValidInput)
                }
            }
        }
    }
    
    // Validate input fields
    private var isValidInput: Bool {
        let askingPriceValid = askingPrice.isEmpty || Double(askingPrice) != nil
        let annualRevenueValid = annualRevenue.isEmpty || Double(annualRevenue) != nil
        let annualProfitValid = annualProfit.isEmpty || Double(annualProfit) != nil
        
        return askingPriceValid && annualRevenueValid && annualProfitValid
    }
    
    // Save the financial data to the business model
    private func saveFinancialData() {
        // Update business properties with new values
        business.askingPrice = Double(askingPrice) ?? 0
        business.annualRevenue = Double(annualRevenue) ?? 0
        business.annualProfit = Double(annualProfit) ?? 0
        
        // Update the timestamp
        business.updatedAt = Date()
        
        // Save the context
        do {
            try modelContext.save()
        } catch {
            print("Failed to save financial data: \(error)")
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
    
    return EditFinancialSummaryView(business: business)
        .modelContainer(for: Business.self, inMemory: true)
}
