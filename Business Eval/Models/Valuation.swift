//
//  Valuation.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import Foundation
import SwiftData

@Model
final class Valuation {
    var id: UUID
    var calculatedValue: Double
    var multiple: Double
    var methodology: ValuationMethodology
    var notes: String?
    var confidenceLevel: ConfidenceLevel
    var createdAt: Date
    
    // Financial metrics used for valuation
    var revenueMultiple: Double?
    var profitMultiple: Double?
    var ebitdaMultiple: Double?
    var sdeMultiple: Double?
    
    // Relationships
    var business: Business?
    
    init(calculatedValue: Double, multiple: Double, methodology: ValuationMethodology, 
         confidenceLevel: ConfidenceLevel, business: Business? = nil) {
        self.id = UUID()
        self.calculatedValue = calculatedValue
        self.multiple = multiple
        self.methodology = methodology
        self.confidenceLevel = confidenceLevel
        self.business = business
        self.createdAt = Date()
    }
}

enum ValuationMethodology: String, CaseIterable, Codable {
    case revenueMultiple = "Revenue Multiple"
    case profitMultiple = "Profit Multiple"
    case ebitdaMultiple = "EBITDA Multiple"
    case sdeMultiple = "SDE Multiple"
    case assetBased = "Asset Based"
    case discountedCashFlow = "Discounted Cash Flow"
    case marketComparison = "Market Comparison"
}

enum ConfidenceLevel: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case veryHigh = "Very High"
}
