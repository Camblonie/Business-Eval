//
//  Business.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import Foundation
import SwiftData

@Model
final class Business {
    var id: UUID
    var name: String
    var industry: String
    var location: String
    var askingPrice: Double
    var annualRevenue: Double
    var annualProfit: Double
    var numberOfEmployees: Int
    var yearsEstablished: Int
    var businessDescription: String
    var listingURL: String?
    var notes: String?
    var status: BusinessStatus
    var createdAt: Date
    var updatedAt: Date
    
    // Loan/Financing fields - defaults for existing records
    var downPaymentPercent: Double = 10.0
    var loanInterestRate: Double = 9.0
    var loanTermYears: Int = 10
    
    // Relationships
    var correspondence: [Correspondence] = []
    var valuations: [Valuation] = []
    var owner: Owner?
    var broker: Broker?
    var images: [BusinessImage] = []
    
    init(name: String, 
         industry: String = "", 
         location: String = "", 
         askingPrice: Double = 0, 
         annualRevenue: Double = 0, 
         annualProfit: Double = 0, 
         numberOfEmployees: Int = 0, 
         yearsEstablished: Int = 0, 
         businessDescription: String = "",
         downPaymentPercent: Double = 10.0,
         loanInterestRate: Double = 9.0,
         loanTermYears: Int = 10) {
        self.id = UUID()
        self.name = name
        self.industry = industry
        self.location = location
        self.askingPrice = askingPrice
        self.annualRevenue = annualRevenue
        self.annualProfit = annualProfit
        self.numberOfEmployees = numberOfEmployees
        self.yearsEstablished = yearsEstablished
        self.businessDescription = businessDescription
        self.downPaymentPercent = downPaymentPercent
        self.loanInterestRate = loanInterestRate
        self.loanTermYears = loanTermYears
        self.status = .new
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Loan Calculations
    
    /// Calculates the down payment amount based on asking price and down payment percentage
    var downPaymentAmount: Double {
        askingPrice * (downPaymentPercent / 100.0)
    }
    
    /// Calculates the loan amount (asking price minus down payment)
    var loanAmount: Double {
        askingPrice - downPaymentAmount
    }
    
    /// Calculates the annual loan payment using amortization formula
    /// Formula: P = L[c(1 + c)^n]/[(1 + c)^n - 1] where:
    /// P = payment, L = loan amount, c = monthly interest rate, n = number of payments
    var annualLoanPayment: Double {
        guard loanAmount > 0, loanInterestRate > 0, loanTermYears > 0 else {
            return 0
        }
        
        let monthlyRate = (loanInterestRate / 100.0) / 12.0
        let numberOfPayments = Double(loanTermYears * 12)
        
        // Amortization formula for monthly payment
        let numerator = monthlyRate * pow(1 + monthlyRate, numberOfPayments)
        let denominator = pow(1 + monthlyRate, numberOfPayments) - 1
        
        let monthlyPayment = loanAmount * (numerator / denominator)
        
        return monthlyPayment * 12.0
    }
    
    /// Monthly loan payment
    var monthlyLoanPayment: Double {
        annualLoanPayment / 12.0
    }
}

enum BusinessStatus: String, CaseIterable, Codable {
    case new = "New"
    case researching = "Researching"
    case contacted = "Contacted"
    case underReview = "Under Review"
    case offerMade = "Offer Made"
    case negotiating = "Negotiating"
    case dueDiligence = "Due Diligence"
    case closed = "Closed"
    case rejected = "Rejected"
    case notInterested = "Not Interested"
}
