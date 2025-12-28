//
//  ValuationScenario.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import Foundation
import SwiftData

@Model
final class ValuationScenario {
    var id: UUID
    var business: Business?
    var scenarioType: ScenarioType
    var baseValuation: Double
    var adjustedRevenue: Double
    var adjustedProfit: Double
    var growthRate: Double
    var riskAdjustment: Double
    var marketConditions: MarketConditions
    var calculatedValue: Double
    var confidenceLevel: ConfidenceLevel
    var assumptions: String?
    var notes: String?
    var createdAt: Date
    
    init(business: Business, scenarioType: ScenarioType, baseValuation: Double,
         adjustedRevenue: Double, adjustedProfit: Double, growthRate: Double,
         riskAdjustment: Double, marketConditions: MarketConditions,
         assumptions: String? = nil, notes: String? = nil) {
        self.id = UUID()
        self.business = business
        self.scenarioType = scenarioType
        self.baseValuation = baseValuation
        self.adjustedRevenue = adjustedRevenue
        self.adjustedProfit = adjustedProfit
        self.growthRate = growthRate
        self.riskAdjustment = riskAdjustment
        self.marketConditions = marketConditions
        self.assumptions = assumptions
        self.notes = notes
        self.createdAt = Date()
        
        // Calculate scenario value inline
        var value = baseValuation
        
        // Apply revenue adjustment
        let revenueMultiplier = adjustedRevenue / (business.annualRevenue > 0 ? business.annualRevenue : 1)
        value *= revenueMultiplier
        
        // Apply profit adjustment
        let profitMultiplier = adjustedProfit / (business.annualProfit > 0 ? business.annualProfit : 1)
        value *= profitMultiplier
        
        // Apply growth rate adjustment
        value *= (1 + growthRate)
        
        // Apply risk adjustment
        value *= (1 - riskAdjustment)
        
        // Apply market conditions
        value *= marketConditions.multiplier
        
        self.calculatedValue = value
        
        // Determine confidence level inline
        switch scenarioType {
        case .optimistic:
            self.confidenceLevel = .medium
        case .realistic:
            self.confidenceLevel = .high
        case .pessimistic:
            self.confidenceLevel = .medium
        case .custom:
            self.confidenceLevel = .low
        }
    }

enum ScenarioType: String, CaseIterable, Codable {
    case optimistic = "Optimistic"
    case realistic = "Realistic"
    case pessimistic = "Pessimistic"
    case custom = "Custom"
}

enum MarketConditions: String, CaseIterable, Codable {
    case excellent = "Excellent"
    case good = "Good"
    case average = "Average"
    case poor = "Poor"
    case recession = "Recession"
    
    var multiplier: Double {
        switch self {
        case .excellent: return 1.3
        case .good: return 1.15
        case .average: return 1.0
        case .poor: return 0.85
        case .recession: return 0.7
        }
    }
    
    var description: String {
        switch self {
        case .excellent:
            return "Strong economic growth, high buyer demand, low interest rates"
        case .good:
            return "Moderate growth, stable demand, reasonable financing"
        case .average:
            return "Normal market conditions, balanced supply and demand"
        case .poor:
            return "Economic uncertainty, reduced demand, higher financing costs"
        case .recession:
            return "Economic downturn, low demand, difficult financing"
        }
    }
}

// Valuation scenario service
class ValuationScenarioService {
    static let shared = ValuationScenarioService()
    
    private init() {}
    
    func generateScenarios(for business: Business, baseValuation: Double) -> [ValuationScenario] {
        var scenarios: [ValuationScenario] = []
        
        // Optimistic scenario
        let optimistic = ValuationScenario(
            business: business,
            scenarioType: .optimistic,
            baseValuation: baseValuation,
            adjustedRevenue: business.annualRevenue * 1.2,
            adjustedProfit: business.annualProfit * 1.3,
            growthRate: 0.15,
            riskAdjustment: 0.05,
            marketConditions: .good,
            assumptions: "Revenue growth of 20%, profit margin improvement, favorable market conditions"
        )
        scenarios.append(optimistic)
        
        // Realistic scenario
        let realistic = ValuationScenario(
            business: business,
            scenarioType: .realistic,
            baseValuation: baseValuation,
            adjustedRevenue: business.annualRevenue,
            adjustedProfit: business.annualProfit,
            growthRate: 0.08,
            riskAdjustment: 0.1,
            marketConditions: .average,
            assumptions: "Current revenue and profit levels maintained, moderate growth, normal market conditions"
        )
        scenarios.append(realistic)
        
        // Pessimistic scenario
        let pessimistic = ValuationScenario(
            business: business,
            scenarioType: .pessimistic,
            baseValuation: baseValuation,
            adjustedRevenue: business.annualRevenue * 0.85,
            adjustedProfit: business.annualProfit * 0.8,
            growthRate: -0.05,
            riskAdjustment: 0.2,
            marketConditions: .poor,
            assumptions: "Revenue decline of 15%, profit margin pressure, challenging market conditions"
        )
        scenarios.append(pessimistic)
        
        return scenarios
    }
    
    func getScenarioAnalysis(scenarios: [ValuationScenario]) -> ScenarioAnalysis {
        guard !scenarios.isEmpty else {
            return ScenarioAnalysis(
                optimisticValue: 0,
                realisticValue: 0,
                pessimisticValue: 0,
                valueRange: 0,
                riskPremium: 0,
                recommendedValue: 0
            )
        }
        
        let optimistic = scenarios.first { $0.scenarioType == .optimistic }?.calculatedValue ?? 0
        let realistic = scenarios.first { $0.scenarioType == .realistic }?.calculatedValue ?? 0
        let pessimistic = scenarios.first { $0.scenarioType == .pessimistic }?.calculatedValue ?? 0
        
        let valueRange = optimistic - pessimistic
        let riskPremium = (optimistic - realistic) / realistic
        let recommendedValue = (optimistic + realistic * 2 + pessimistic) / 4 // Weighted average
        
        return ScenarioAnalysis(
            optimisticValue: optimistic,
            realisticValue: realistic,
            pessimisticValue: pessimistic,
            valueRange: valueRange,
            riskPremium: riskPremium,
            recommendedValue: recommendedValue
        )
    }
}

struct ScenarioAnalysis {
    let optimisticValue: Double
    let realisticValue: Double
    let pessimisticValue: Double
    let valueRange: Double
    let riskPremium: Double
    let recommendedValue: Double
    
    var riskLevel: String {
        let riskRatio = valueRange / realisticValue
        
        switch riskRatio {
        case 0..<0.3:
            return "Low Risk"
        case 0.3..<0.6:
            return "Medium Risk"
        default:
            return "High Risk"
        }
    }
    
    var investmentRecommendation: String {
        let upsidePotential = (optimisticValue - realisticValue) / realisticValue
        let downsideRisk = (realisticValue - pessimisticValue) / realisticValue
        
        if upsidePotential > 0.3 && downsideRisk < 0.2 {
            return "Strong Buy - High upside with limited downside"
        } else if upsidePotential > 0.2 && downsideRisk < 0.3 {
            return "Buy - Good risk-reward balance"
        } else if upsidePotential > 0.1 {
            return "Consider - Moderate opportunity with some risk"
        } else {
            return "Avoid - Limited upside with significant risk"
        }
    }
}
