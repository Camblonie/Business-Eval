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
    
    // Loan/Financing state variables
    @State private var downPaymentPercent: Double
    @State private var loanInterestRate: Double
    @State private var loanTermYears: Int
    
    init(business: Business) {
        self.business = business
        // Initialize with current business values
        self._askingPrice = State(initialValue: business.askingPrice == 0 ? "" : String(business.askingPrice))
        self._annualRevenue = State(initialValue: business.annualRevenue == 0 ? "" : String(business.annualRevenue))
        self._annualProfit = State(initialValue: business.annualProfit == 0 ? "" : String(business.annualProfit))
        
        // Initialize loan values
        self._downPaymentPercent = State(initialValue: business.downPaymentPercent)
        self._loanInterestRate = State(initialValue: business.loanInterestRate)
        self._loanTermYears = State(initialValue: business.loanTermYears)
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
                
                // Loan/Financing Section
                Section(header: Text("Financing Details")) {
                    // Down Payment Percentage
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Down Payment")
                                .font(.headline)
                            Spacer()
                            Text("\(Int(downPaymentPercent))%")
                                .font(.headline)
                                .foregroundColor(AppTheme.Colors.primary)
                        }
                        
                        Slider(value: $downPaymentPercent, in: 0...100, step: 5)
                        
                        // Show calculated down payment amount
                        if let price = Double(askingPrice), price > 0 {
                            Text("Down Payment: \(formatCurrency(price * downPaymentPercent / 100))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Loan Interest Rate
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Interest Rate")
                                .font(.headline)
                            Spacer()
                            Text(String(format: "%.2f%%", loanInterestRate))
                                .font(.headline)
                                .foregroundColor(AppTheme.Colors.primary)
                        }
                        
                        Slider(value: $loanInterestRate, in: 0...20, step: 0.25)
                        
                        HStack {
                            Text("0%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("20%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Loan Term
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Loan Term")
                                .font(.headline)
                            Spacer()
                            Text("\(loanTermYears) years")
                                .font(.headline)
                                .foregroundColor(AppTheme.Colors.primary)
                        }
                        
                        Picker("Loan Term", selection: $loanTermYears) {
                            ForEach([5, 7, 10, 15, 20, 25, 30], id: \.self) { years in
                                Text("\(years) years").tag(years)
                            }
                        }
                        .pickerStyle(.segmented)
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
                
                // Loan Payment Preview
                if let price = Double(askingPrice), price > 0, loanInterestRate > 0, loanTermYears > 0 {
                    Section(header: Text("Loan Payment Preview")) {
                        let downPayment = price * (downPaymentPercent / 100.0)
                        let loanAmount = price - downPayment
                        let annualPayment = calculateAnnualPayment(loanAmount: loanAmount, rate: loanInterestRate, years: loanTermYears)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Down Payment")
                                Spacer()
                                Text(formatCurrency(downPayment))
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("Loan Amount")
                                Spacer()
                                Text(formatCurrency(loanAmount))
                                    .fontWeight(.medium)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Annual Payment")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(formatCurrency(annualPayment))
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.Colors.warning)
                            }
                            
                            HStack {
                                Text("Monthly Payment")
                                Spacer()
                                Text(formatCurrency(annualPayment / 12.0))
                                    .fontWeight(.medium)
                                    .foregroundColor(AppTheme.Colors.warning)
                            }
                            
                            // Cash flow analysis if profit is available
                            if let profit = Double(annualProfit), profit > 0 {
                                Divider()
                                
                                let cashFlowAfterDebt = profit - annualPayment
                                HStack {
                                    Text("Cash Flow After Debt")
                                    Spacer()
                                    Text(formatCurrency(cashFlowAfterDebt))
                                        .fontWeight(.medium)
                                        .foregroundColor(cashFlowAfterDebt >= 0 ? AppTheme.Colors.success : AppTheme.Colors.destructive)
                                }
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
        
        // Update loan/financing properties
        business.downPaymentPercent = downPaymentPercent
        business.loanInterestRate = loanInterestRate
        business.loanTermYears = loanTermYears
        
        // Update the timestamp
        business.updatedAt = Date()
        
        // Save the context
        do {
            try modelContext.save()
        } catch {
            print("Failed to save financial data: \(error)")
        }
    }
    
    // MARK: - Helper Functions
    
    /// Calculates annual loan payment using amortization formula
    private func calculateAnnualPayment(loanAmount: Double, rate: Double, years: Int) -> Double {
        guard loanAmount > 0, rate > 0, years > 0 else { return 0 }
        
        let monthlyRate = (rate / 100.0) / 12.0
        let numberOfPayments = Double(years * 12)
        
        let numerator = monthlyRate * pow(1 + monthlyRate, numberOfPayments)
        let denominator = pow(1 + monthlyRate, numberOfPayments) - 1
        
        let monthlyPayment = loanAmount * (numerator / denominator)
        return monthlyPayment * 12.0
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
