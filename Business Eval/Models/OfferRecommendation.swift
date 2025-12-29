//
//  OfferRecommendation.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import Foundation

struct OfferRecommendation {
    let executiveSummary: String
    let confidenceLevel: ConfidenceLevel
    let minimumOffer: Double
    let recommendedOffer: Double
    let maximumOffer: Double
    let openingOffer: Double
    let averageValuation: Double
    let valuationRange: ClosedRange<Double>
    let discountToAsking: Double
    let industryComparison: String
    let marketPositionScore: Double
    let marketFactors: [MarketFactor]
    let openingStrategy: String
    let keyTalkingPoints: [String]
    let concessionStrategy: String
    let riskFactors: [RiskFactor]
    let nextSteps: [NextStep]
}

struct MarketFactor: Hashable {
    let description: String
    let isPositive: Bool
}

struct RiskFactor: Hashable {
    let title: String
    let description: String
    let severity: RiskSeverity
    let mitigation: String
}

struct NextStep: Hashable {
    let order: Int
    let description: String
}

enum RiskSeverity: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}

class OfferRecommendationService {
    func generateRecommendation(for business: Business) -> OfferRecommendation {
        let valuations = business.valuations
        let averageValuation = valuations.isEmpty ? business.askingPrice : valuations.reduce(0) { $0 + $1.calculatedValue } / Double(valuations.count)
        
        let valuationRange = valuations.isEmpty ? business.askingPrice...business.askingPrice : 
            (valuations.map(\.calculatedValue).min() ?? business.askingPrice)...(valuations.map(\.calculatedValue).max() ?? business.askingPrice)
        
        // Calculate offer range based on valuations and market factors
        let discountToAsking = calculateDiscountToAsking(business: business, averageValuation: averageValuation)
        let recommendedOffer = business.askingPrice * (1 - discountToAsking)
        let minimumOffer = recommendedOffer * 0.85
        let maximumOffer = recommendedOffer * 1.15
        let openingOffer = minimumOffer * 0.9
        
        // Market position analysis
        let marketPositionScore = calculateMarketPositionScore(business: business)
        let marketFactors = generateMarketFactors(business: business)
        
        // Risk assessment
        let riskFactors = generateRiskFactors(business: business)
        
        // Generate recommendation components
        let executiveSummary = generateExecutiveSummary(
            business: business,
            recommendedOffer: recommendedOffer,
            discountToAsking: discountToAsking
        )
        
        let confidenceLevel = determineConfidenceLevel(
            business: business,
            valuations: valuations,
            riskFactors: riskFactors
        )
        
        let industryComparison = generateIndustryComparison(business: business)
        
        let openingStrategy = generateOpeningStrategy(
            business: business,
            openingOffer: openingOffer,
            recommendedOffer: recommendedOffer
        )
        
        let keyTalkingPoints = generateKeyTalkingPoints(
            business: business,
            recommendedOffer: recommendedOffer,
            averageValuation: averageValuation
        )
        
        let concessionStrategy = generateConcessionStrategy(
            minimumOffer: minimumOffer,
            recommendedOffer: recommendedOffer,
            maximumOffer: maximumOffer
        )
        
        let nextSteps = generateNextSteps(business: business)
        
        return OfferRecommendation(
            executiveSummary: executiveSummary,
            confidenceLevel: confidenceLevel,
            minimumOffer: minimumOffer,
            recommendedOffer: recommendedOffer,
            maximumOffer: maximumOffer,
            openingOffer: openingOffer,
            averageValuation: averageValuation,
            valuationRange: valuationRange,
            discountToAsking: discountToAsking,
            industryComparison: industryComparison,
            marketPositionScore: marketPositionScore,
            marketFactors: marketFactors,
            openingStrategy: openingStrategy,
            keyTalkingPoints: keyTalkingPoints,
            concessionStrategy: concessionStrategy,
            riskFactors: riskFactors,
            nextSteps: nextSteps
        )
    }
    
    private func calculateDiscountToAsking(business: Business, averageValuation: Double) -> Double {
        let discount = (business.askingPrice - averageValuation) / business.askingPrice
        
        // Apply market conditions adjustment
        let marketAdjustment = getMarketAdjustment(for: business.industry)
        
        return max(0.05, min(0.30, discount + marketAdjustment))
    }
    
    private func getMarketAdjustment(for industry: String) -> Double {
        // Industry-specific market adjustments
        switch industry.lowercased() {
        case "technology":
            return 0.05 // Tech businesses often command premium
        case "manufacturing":
            return -0.02 // Manufacturing may be undervalued
        case "retail":
            return 0.02 // Retail has moderate adjustments
        case "services":
            return 0.03 // Service businesses have good margins
        default:
            return 0.0
        }
    }
    
    private func calculateMarketPositionScore(business: Business) -> Double {
        var score: Double = 0.5 // Base score
        
        // Revenue size factor
        if business.annualRevenue > 2000000 {
            score += 0.2
        } else if business.annualRevenue > 1000000 {
            score += 0.1
        }
        
        // Profit margin factor
        let profitMargin = business.annualRevenue > 0 ? business.annualProfit / business.annualRevenue : 0
        if profitMargin > 0.25 {
            score += 0.2
        } else if profitMargin > 0.15 {
            score += 0.1
        }
        
        // Growth potential factor
        if business.yearsEstablished < 5 {
            score += 0.1
        }
        
        return min(1.0, max(0.0, score))
    }
    
    private func generateMarketFactors(business: Business) -> [MarketFactor] {
        var factors: [MarketFactor] = []
        
        // Revenue growth potential
        if business.annualRevenue > 1000000 {
            factors.append(MarketFactor(
                description: "Strong revenue base provides stability",
                isPositive: true
            ))
        }
        
        // Profit margin analysis
        let profitMargin = business.annualRevenue > 0 ? business.annualProfit / business.annualRevenue : 0
        if profitMargin > 0.2 {
            factors.append(MarketFactor(
                description: "Healthy profit margins indicate efficiency",
                isPositive: true
            ))
        } else if profitMargin < 0.1 {
            factors.append(MarketFactor(
                description: "Low profit margins may indicate operational issues",
                isPositive: false
            ))
        }
        
        // Industry position
        factors.append(MarketFactor(
            description: "\(business.industry) industry has \(getIndustryOutlook(business.industry)) outlook",
            isPositive: getIndustryOutlook(business.industry) == "positive"
        ))
        
        return factors
    }
    
    private func getIndustryOutlook(_ industry: String) -> String {
        switch industry.lowercased() {
        case "technology", "healthcare", "financial services":
            return "positive"
        case "manufacturing", "retail":
            return "moderate"
        default:
            return "neutral"
        }
    }
    
    private func generateRiskFactors(business: Business) -> [RiskFactor] {
        var factors: [RiskFactor] = []
        
        // Valuation consistency risk
        if business.valuations.count >= 3 {
            let values = business.valuations.map(\.calculatedValue)
            let variance = values.max()! - values.min()!
            let avgValue = values.reduce(0, +) / Double(values.count)
            
            if variance / avgValue > 0.3 {
                factors.append(RiskFactor(
                    title: "Valuation Variance",
                    description: "High variance between valuations indicates uncertainty",
                    severity: .medium,
                    mitigation: "Seek additional valuation methods or professional appraisal"
                ))
            }
        }
        
        // Profit margin risk
        let profitMargin = business.annualRevenue > 0 ? business.annualProfit / business.annualRevenue : 0
        if profitMargin < 0.1 {
            factors.append(RiskFactor(
                title: "Low Profit Margin",
                description: "Profit margin below 10% may indicate operational challenges",
                severity: .high,
                mitigation: "Investigate cost structure and efficiency improvements"
            ))
        }
        
        // Industry risk
        let industryRisk = getIndustryRisk(business.industry)
        if industryRisk != .low {
            factors.append(RiskFactor(
                title: "Industry Risk",
                description: "\(business.industry) industry faces \(industryRisk.rawValue) risk factors",
                severity: industryRisk,
                mitigation: "Conduct thorough industry analysis and competitive assessment"
            ))
        }
        
        // Size risk
        if business.annualRevenue < 500000 {
            factors.append(RiskFactor(
                title: "Small Business Risk",
                description: "Small revenue base may be vulnerable to market changes",
                severity: .medium,
                mitigation: "Diversify revenue streams and strengthen customer relationships"
            ))
        }
        
        return factors
    }
    
    private func getIndustryRisk(_ industry: String) -> RiskSeverity {
        switch industry.lowercased() {
        case "technology", "financial services":
            return .high
        case "healthcare", "services":
            return .medium
        case "manufacturing", "retail":
            return .medium
        default:
            return .low
        }
    }
    
    private func generateExecutiveSummary(business: Business, recommendedOffer: Double, discountToAsking: Double) -> String {
        let discountPercentage = String(format: "%.1f", discountToAsking * 100)
        
        return """
        Based on comprehensive valuation analysis and market assessment, we recommend an offer of $\(String(format: "%.0f", recommendedOffer)) for \(business.name). This represents a \(discountPercentage)% discount to the asking price and aligns with industry standards for \(business.industry) businesses. The recommendation considers multiple valuation methods, market conditions, and risk factors to provide a balanced offer position.
        """
    }
    
    private func determineConfidenceLevel(business: Business, valuations: [Valuation], riskFactors: [RiskFactor]) -> ConfidenceLevel {
        var confidenceScore: Int = 3 // Start at medium
        
        // Valuation consistency
        if valuations.count >= 3 {
            confidenceScore += 1
        } else if valuations.count == 0 {
            confidenceScore -= 1
        }
        
        // Risk factors
        let highRiskCount = riskFactors.filter { $0.severity == .high || $0.severity == .critical }.count
        confidenceScore -= highRiskCount
        
        // Data quality
        if business.annualRevenue > 0 && business.annualProfit > 0 {
            confidenceScore += 1
        }
        
        switch confidenceScore {
        case 0...1: return .low
        case 2...3: return .medium
        case 4...5: return .high
        default: return .veryHigh
        }
    }
    
    private func generateIndustryComparison(business: Business) -> String {
        let service = IndustryBenchmarkService.shared
        let benchmark = service.getBenchmark(for: business.industry)
        
        if let benchmark = benchmark {
            let revenueMultiple = business.askingPrice / business.annualRevenue
            let comparison = revenueMultiple / benchmark.revenueMultiple
            
            if comparison > 1.2 {
                return "Above industry average by \(String(format: "%.0f", (comparison - 1) * 100))%"
            } else if comparison < 0.8 {
                return "Below industry average by \(String(format: "%.0f", (1 - comparison) * 100))%"
            } else {
                return "In line with industry averages"
            }
        }
        
        return "No industry data available"
    }
    
    private func generateOpeningStrategy(business: Business, openingOffer: Double, recommendedOffer: Double) -> String {
        return """
        Begin negotiations at $\(String(format: "%.0f", openingOffer)) to establish an anchor point. This position is supported by valuation analysis and provides room for concessions while maintaining a strong negotiating position. Be prepared to justify this offer with specific valuation metrics and market comparables.
        """
    }
    
    private func generateKeyTalkingPoints(business: Business, recommendedOffer: Double, averageValuation: Double) -> [String] {
        return [
            "Our offer of $\(String(format: "%.0f", recommendedOffer)) reflects comprehensive valuation analysis",
            "Average independent valuation: $\(String(format: "%.0f", averageValuation))",
            "Current market conditions in \(business.industry) industry",
            "Profit margin analysis and growth potential",
            "Comparable business sales in the market",
            "Risk factors and mitigation strategies"
        ]
    }
    
    private func generateConcessionStrategy(minimumOffer: Double, recommendedOffer: Double, maximumOffer: Double) -> String {
        let concessionRange = maximumOffer - minimumOffer
        let recommendedConcession = (recommendedOffer - minimumOffer) / concessionRange
        
        return """
        Plan concessions in phases: initial offer at minimum, target offer at \(String(format: "%.0f", recommendedConcession * 100))% of range, maximum offer as final position. Each concession should be justified with additional value discovery or seller concessions. Maintain discipline to avoid emotional bidding.
        """
    }
    
    private func generateNextSteps(business: Business) -> [NextStep] {
        return [
            NextStep(order: 1, description: "Prepare detailed valuation report with supporting documentation"),
            NextStep(order: 2, description: "Research recent comparable sales in \(business.industry) industry"),
            NextStep(order: 3, description: "Prepare letter of intent with proposed terms"),
            NextStep(order: 4, description: "Schedule initial meeting with business owner"),
            NextStep(order: 5, description: "Conduct due diligence investigation"),
            NextStep(order: 6, description: "Finalize purchase agreement and close transaction")
        ]
    }
}
