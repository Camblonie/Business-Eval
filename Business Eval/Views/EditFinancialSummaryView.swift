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
    
    // Real Estate state variables
    @State private var realEstateIncluded: Bool
    @State private var realEstateIncludedInPrice: Bool
    @State private var realEstateValue: String
    @State private var realEstateSquareFeet: String
    @State private var realEstatePricePerSqFt: String
    @State private var realEstateDescription: String
    @State private var realEstateNotes: String
    @State private var realEstateLeaseCostPerMonth: String
    
    // RE-specific financing state variables
    @State private var realEstateLoanTermYears: Int
    @State private var realEstateInterestRate: Double
    @State private var realEstateDownPaymentPercent: Double
    
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
        
        // Initialize real estate values
        self._realEstateIncluded = State(initialValue: business.realEstateIncluded)
        self._realEstateIncludedInPrice = State(initialValue: business.realEstateIncludedInPrice)
        self._realEstateValue = State(initialValue: business.realEstateValue == 0 ? "" : String(business.realEstateValue))
        self._realEstateSquareFeet = State(initialValue: business.realEstateSquareFeet == 0 ? "" : String(business.realEstateSquareFeet))
        self._realEstatePricePerSqFt = State(initialValue: business.realEstatePricePerSqFt == 0 ? "" : String(business.realEstatePricePerSqFt))
        self._realEstateDescription = State(initialValue: business.realEstateDescription ?? "")
        self._realEstateNotes = State(initialValue: business.realEstateNotes ?? "")
        self._realEstateLeaseCostPerMonth = State(initialValue: business.realEstateLeaseCostPerMonth == 0 ? "" : String(business.realEstateLeaseCostPerMonth))
        
        // Initialize RE financing values
        self._realEstateLoanTermYears = State(initialValue: business.realEstateLoanTermYears)
        self._realEstateInterestRate = State(initialValue: business.realEstateInterestRate)
        self._realEstateDownPaymentPercent = State(initialValue: business.realEstateDownPaymentPercent)
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
                                .keyboardType(.numbersAndPunctuation)
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
                
                // Real Estate Section
                Section(header: Text("Real Estate")) {
                    // Toggle: does this deal include real estate?
                    Toggle(isOn: $realEstateIncluded) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Real Estate Included")
                                .font(.headline)
                            Text("Property is part of this deal")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Show RE detail fields when RE is part of the deal
                    if realEstateIncluded {
                        // Toggle: is the RE price bundled in the business asking price?
                        Toggle(isOn: $realEstateIncludedInPrice) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Included in Asking Price")
                                    .font(.headline)
                                Text("RE value is bundled into the business asking price")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // RE Value — always shown so the user can record/enter it
                        VStack(alignment: .leading, spacing: 4) {
                            Text(realEstateIncludedInPrice ? "Real Estate Value" : "Real Estate Valuation")
                                .font(.headline)
                            
                            if !realEstateIncludedInPrice {
                                Text("Enter the appraised or estimated value of the real estate")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.Colors.warning)
                            }
                            
                            HStack {
                                Text("$")
                                    .foregroundColor(.secondary)
                                TextField("0", text: $realEstateValue)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            // Show business-only price when RE is bundled in
                            if realEstateIncludedInPrice, let price = Double(askingPrice), price > 0,
                               let reValue = Double(realEstateValue), reValue > 0 {
                                let businessOnly = max(price - reValue, 0)
                                Text("Business-Only Value: \(formatCurrency(businessOnly))")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // Square Footage
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Square Footage")
                                .font(.headline)
                            
                            HStack {
                                TextField("0", text: $realEstateSquareFeet)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Text("sq ft")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // Price Per Square Foot
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Price Per Square Foot")
                                .font(.headline)
                            
                            HStack {
                                Text("$")
                                    .foregroundColor(.secondary)
                                TextField("0", text: $realEstatePricePerSqFt)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Text("/sq ft")
                                    .foregroundColor(.secondary)
                            }
                            
                            // Auto-calculate hint
                            if let sqft = Double(realEstateSquareFeet), sqft > 0,
                               let value = Double(realEstateValue), value > 0 {
                                let calculatedPricePerSqFt = value / sqft
                                Text("Calculated: \(formatCurrency(calculatedPricePerSqFt))/sq ft")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // Lease cost — always shown regardless of ownership type
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Lease / Rent Cost Per Month")
                                .font(.headline)
                            Text("Enter the monthly lease or equivalent market rent")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text("$")
                                    .foregroundColor(.secondary)
                                TextField("0", text: $realEstateLeaseCostPerMonth)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Text("/mo")
                                    .foregroundColor(.secondary)
                            }
                            
                            // Show annual lease cost
                            if let monthly = Double(realEstateLeaseCostPerMonth), monthly > 0 {
                                Text("Annual: \(formatCurrency(monthly * 12))")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // Property Description
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Property Description")
                                .font(.headline)
                            
                            TextField("Type, size, features...", text: $realEstateDescription, axis: .vertical)
                                .lineLimit(2...4)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.vertical, 4)
                        
                        // Real Estate Notes
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Real Estate Notes")
                                .font(.headline)
                            
                            TextField("Additional notes...", text: $realEstateNotes, axis: .vertical)
                                .lineLimit(2...4)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // RE Financing Section — only when RE is included and has a value
                if realEstateIncluded, let reValue = Double(realEstateValue), reValue > 0 {
                    Section(header: Text("Real Estate Financing")) {
                        // RE Down Payment
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("RE Down Payment")
                                    .font(.headline)
                                Spacer()
                                Text("\(Int(realEstateDownPaymentPercent))%")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                            
                            Slider(value: $realEstateDownPaymentPercent, in: 0...100, step: 5)
                            
                            Text("Down Payment: \(formatCurrency(reValue * realEstateDownPaymentPercent / 100))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        
                        // RE Interest Rate
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("RE Interest Rate")
                                    .font(.headline)
                                Spacer()
                                Text(String(format: "%.2f%%", realEstateInterestRate))
                                    .font(.headline)
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                            
                            Slider(value: $realEstateInterestRate, in: 0...20, step: 0.25)
                        }
                        .padding(.vertical, 4)
                        
                        // RE Loan Term (default 25 years)
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("RE Loan Term")
                                    .font(.headline)
                                Spacer()
                                Text("\(realEstateLoanTermYears) years")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                            
                            Picker("RE Loan Term", selection: $realEstateLoanTermYears) {
                                ForEach([10, 15, 20, 25, 30], id: \.self) { years in
                                    Text("\(years) years").tag(years)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.vertical, 4)
                    }
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
                                let profitValue = Double(annualProfit) ?? 0
                                FinancialRow(label: "Annual Profit", value: profitValue, color: profitValue < 0 ? .red : .purple)
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
                
                // Business Loan Payment Preview
                if let price = Double(askingPrice), price > 0, loanInterestRate > 0, loanTermYears > 0 {
                    // Calculate business-only price (subtract RE if bundled in)
                    let reVal = Double(realEstateValue) ?? 0
                    let businessPrice = (realEstateIncluded && realEstateIncludedInPrice && reVal > 0) ? max(price - reVal, 0) : price
                    let downPayment = businessPrice * (downPaymentPercent / 100.0)
                    let bizLoanAmount = businessPrice - downPayment
                    let bizAnnualPayment = calculateAnnualPayment(loanAmount: bizLoanAmount, rate: loanInterestRate, years: loanTermYears)
                    
                    Section(header: Text("Business Loan Preview")) {
                        VStack(spacing: 8) {
                            if realEstateIncluded && realEstateIncludedInPrice && reVal > 0 {
                                HStack {
                                    Text("Business-Only Price")
                                    Spacer()
                                    Text(formatCurrency(businessPrice))
                                        .fontWeight(.medium)
                                }
                            }
                            
                            HStack {
                                Text("Down Payment")
                                Spacer()
                                Text(formatCurrency(downPayment))
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("Loan Amount")
                                Spacer()
                                Text(formatCurrency(bizLoanAmount))
                                    .fontWeight(.medium)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Annual Payment")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(formatCurrency(bizAnnualPayment))
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.Colors.warning)
                            }
                            
                            HStack {
                                Text("Monthly Payment")
                                Spacer()
                                Text(formatCurrency(bizAnnualPayment / 12.0))
                                    .fontWeight(.medium)
                                    .foregroundColor(AppTheme.Colors.warning)
                            }
                        }
                    }
                    
                    // RE Loan Payment Preview — shown when RE has a value
                    if realEstateIncluded && reVal > 0 && realEstateInterestRate > 0 && realEstateLoanTermYears > 0 {
                        let reDown = reVal * (realEstateDownPaymentPercent / 100.0)
                        let reLoanAmt = reVal - reDown
                        let reAnnualPayment = calculateAnnualPayment(loanAmount: reLoanAmt, rate: realEstateInterestRate, years: realEstateLoanTermYears)
                        
                        Section(header: Text("RE Loan Preview")) {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("RE Value")
                                    Spacer()
                                    Text(formatCurrency(reVal))
                                        .fontWeight(.medium)
                                }
                                
                                HStack {
                                    Text("Down Payment")
                                    Spacer()
                                    Text(formatCurrency(reDown))
                                        .fontWeight(.medium)
                                }
                                
                                HStack {
                                    Text("Loan Amount")
                                    Spacer()
                                    Text(formatCurrency(reLoanAmt))
                                        .fontWeight(.medium)
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Annual Payment")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(formatCurrency(reAnnualPayment))
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.Colors.warning)
                                }
                                
                                HStack {
                                    Text("Monthly Payment")
                                    Spacer()
                                    Text(formatCurrency(reAnnualPayment / 12.0))
                                        .fontWeight(.medium)
                                        .foregroundColor(AppTheme.Colors.warning)
                                }
                            }
                        }
                        
                        // Combined totals section
                        let totalAnnual = bizAnnualPayment + reAnnualPayment
                        Section(header: Text("Combined Debt Service")) {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Total Annual Debt Service")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(formatCurrency(totalAnnual))
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.Colors.warning)
                                }
                                
                                HStack {
                                    Text("Total Monthly Debt Service")
                                    Spacer()
                                    Text(formatCurrency(totalAnnual / 12.0))
                                        .fontWeight(.medium)
                                        .foregroundColor(AppTheme.Colors.warning)
                                }
                                
                                // Cash flow analysis
                                if let profit = Double(annualProfit), profit > 0 {
                                    Divider()
                                    
                                    let cashFlow = profit - totalAnnual
                                    HStack {
                                        Text("Cash Flow After Debt")
                                        Spacer()
                                        Text(formatCurrency(cashFlow))
                                            .fontWeight(.medium)
                                            .foregroundColor(cashFlow >= 0 ? AppTheme.Colors.success : AppTheme.Colors.destructive)
                                    }
                                    
                                    let dscr = totalAnnual > 0 ? profit / totalAnnual : 0
                                    HStack {
                                        Text("Debt Service Coverage")
                                        Spacer()
                                        Text(String(format: "%.2fx", dscr))
                                            .fontWeight(.medium)
                                            .foregroundColor(dscr >= 1.25 ? AppTheme.Colors.success : (dscr >= 1.0 ? AppTheme.Colors.warning : AppTheme.Colors.destructive))
                                    }
                                }
                            }
                        }
                    } else {
                        // No RE — show simple cash flow on the business-only preview
                        if let profit = Double(annualProfit), profit > 0 {
                            Section(header: Text("Cash Flow Analysis")) {
                                let cashFlow = profit - bizAnnualPayment
                                HStack {
                                    Text("Cash Flow After Debt")
                                    Spacer()
                                    Text(formatCurrency(cashFlow))
                                        .fontWeight(.medium)
                                        .foregroundColor(cashFlow >= 0 ? AppTheme.Colors.success : AppTheme.Colors.destructive)
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
        
        // Update real estate properties
        business.realEstateIncluded = realEstateIncluded
        business.realEstateIncludedInPrice = realEstateIncludedInPrice
        business.realEstateValue = Double(realEstateValue) ?? 0
        business.realEstateSquareFeet = Double(realEstateSquareFeet) ?? 0
        business.realEstatePricePerSqFt = Double(realEstatePricePerSqFt) ?? 0
        business.realEstateDescription = realEstateDescription.isEmpty ? nil : realEstateDescription
        business.realEstateNotes = realEstateNotes.isEmpty ? nil : realEstateNotes
        business.realEstateLeaseCostPerMonth = Double(realEstateLeaseCostPerMonth) ?? 0
        
        // Update RE financing properties
        business.realEstateLoanTermYears = realEstateLoanTermYears
        business.realEstateInterestRate = realEstateInterestRate
        business.realEstateDownPaymentPercent = realEstateDownPaymentPercent
        
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
