//
//  IndustryBenchmark.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import Foundation
import SwiftData

@Model
final class IndustryBenchmark {
    var id: UUID
    var industry: String
    var revenueMultiple: Double
    var profitMultiple: Double
    var ebitdaMultiple: Double
    var sdeMultiple: Double
    var averageBusinessSize: Double
    var typicalGrowthRate: Double
    var riskLevel: RiskLevel
    var lastUpdated: Date
    var dataSource: String?
    
    init(industry: String, revenueMultiple: Double, profitMultiple: Double, 
         ebitdaMultiple: Double, sdeMultiple: Double, averageBusinessSize: Double,
         typicalGrowthRate: Double, riskLevel: RiskLevel, dataSource: String? = nil) {
        self.id = UUID()
        self.industry = industry
        self.revenueMultiple = revenueMultiple
        self.profitMultiple = profitMultiple
        self.ebitdaMultiple = ebitdaMultiple
        self.sdeMultiple = sdeMultiple
        self.averageBusinessSize = averageBusinessSize
        self.typicalGrowthRate = typicalGrowthRate
        self.riskLevel = riskLevel
        self.lastUpdated = Date()
        self.dataSource = dataSource
    }
}

enum RiskLevel: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case veryHigh = "Very High"
}

// Industry benchmarks data service
class IndustryBenchmarkService {
    static let shared = IndustryBenchmarkService()
    
    private init() {}
    
    func getDefaultBenchmarks() -> [IndustryBenchmark] {
        return [
            // Technology
            IndustryBenchmark(
                industry: "Technology",
                revenueMultiple: 4.5,
                profitMultiple: 15.0,
                ebitdaMultiple: 12.0,
                sdeMultiple: 6.0,
                averageBusinessSize: 2500000,
                typicalGrowthRate: 0.25,
                riskLevel: .high,
                dataSource: "Industry Reports 2024"
            ),
            
            // Manufacturing
            IndustryBenchmark(
                industry: "Manufacturing",
                revenueMultiple: 1.2,
                profitMultiple: 8.5,
                ebitdaMultiple: 7.0,
                sdeMultiple: 4.0,
                averageBusinessSize: 5000000,
                typicalGrowthRate: 0.08,
                riskLevel: .medium,
                dataSource: "Industry Reports 2024"
            ),
            
            // Retail
            IndustryBenchmark(
                industry: "Retail",
                revenueMultiple: 0.8,
                profitMultiple: 12.0,
                ebitdaMultiple: 6.5,
                sdeMultiple: 3.5,
                averageBusinessSize: 1200000,
                typicalGrowthRate: 0.05,
                riskLevel: .medium,
                dataSource: "Industry Reports 2024"
            ),
            
            // Services
            IndustryBenchmark(
                industry: "Services",
                revenueMultiple: 2.8,
                profitMultiple: 10.0,
                ebitdaMultiple: 8.5,
                sdeMultiple: 4.5,
                averageBusinessSize: 800000,
                typicalGrowthRate: 0.15,
                riskLevel: .low,
                dataSource: "Industry Reports 2024"
            ),
            
            // Healthcare
            IndustryBenchmark(
                industry: "Healthcare",
                revenueMultiple: 3.2,
                profitMultiple: 18.0,
                ebitdaMultiple: 14.0,
                sdeMultiple: 7.0,
                averageBusinessSize: 3500000,
                typicalGrowthRate: 0.12,
                riskLevel: .low,
                dataSource: "Industry Reports 2024"
            ),
            
            // Construction
            IndustryBenchmark(
                industry: "Construction",
                revenueMultiple: 0.9,
                profitMultiple: 7.5,
                ebitdaMultiple: 6.0,
                sdeMultiple: 3.8,
                averageBusinessSize: 3000000,
                typicalGrowthRate: 0.06,
                riskLevel: .high,
                dataSource: "Industry Reports 2024"
            ),
            
            // Food & Beverage
            IndustryBenchmark(
                industry: "Food & Beverage",
                revenueMultiple: 1.5,
                profitMultiple: 9.0,
                ebitdaMultiple: 7.5,
                sdeMultiple: 4.2,
                averageBusinessSize: 900000,
                typicalGrowthRate: 0.08,
                riskLevel: .medium,
                dataSource: "Industry Reports 2024"
            ),
            
            // Real Estate
            IndustryBenchmark(
                industry: "Real Estate",
                revenueMultiple: 6.0,
                profitMultiple: 12.5,
                ebitdaMultiple: 10.0,
                sdeMultiple: 5.5,
                averageBusinessSize: 4500000,
                typicalGrowthRate: 0.10,
                riskLevel: .low,
                dataSource: "Industry Reports 2024"
            ),
            
            // Financial Services
            IndustryBenchmark(
                industry: "Financial Services",
                revenueMultiple: 5.5,
                profitMultiple: 20.0,
                ebitdaMultiple: 16.0,
                sdeMultiple: 8.0,
                averageBusinessSize: 8000000,
                typicalGrowthRate: 0.18,
                riskLevel: .veryHigh,
                dataSource: "Industry Reports 2024"
            ),
            
            // Transportation
            IndustryBenchmark(
                industry: "Transportation",
                revenueMultiple: 1.1,
                profitMultiple: 8.0,
                ebitdaMultiple: 6.5,
                sdeMultiple: 3.9,
                averageBusinessSize: 2200000,
                typicalGrowthRate: 0.07,
                riskLevel: .high,
                dataSource: "Industry Reports 2024"
            )
        ]
    }
    
    func getBenchmark(for industry: String) -> IndustryBenchmark? {
        let benchmarks = getDefaultBenchmarks()
        
        // Try exact match first
        if let exact = benchmarks.first(where: { $0.industry.lowercased() == industry.lowercased() }) {
            return exact
        }
        
        // Try partial match
        if let partial = benchmarks.first(where: { 
            $0.industry.lowercased().contains(industry.lowercased()) || 
            industry.lowercased().contains($0.industry.lowercased())
        }) {
            return partial
        }
        
        // Return generic services benchmark as fallback
        return benchmarks.first(where: { $0.industry == "Services" })
    }
    
    func getComparisonAnalysis(business: Business, benchmark: IndustryBenchmark) -> BenchmarkAnalysis {
        let revenueMultipleComparison = (business.annualRevenue > 0) ? 
            (business.askingPrice / business.annualRevenue) / benchmark.revenueMultiple : 0
        
        let profitMultipleComparison = (business.annualProfit > 0) ? 
            (business.askingPrice / business.annualProfit) / benchmark.profitMultiple : 0
        
        let sizeComparison = business.annualRevenue / benchmark.averageBusinessSize
        let growthComparison = business.annualRevenue / (business.annualRevenue * (1 + benchmark.typicalGrowthRate))
        
        return BenchmarkAnalysis(
            industry: benchmark.industry,
            revenueMultipleComparison: revenueMultipleComparison,
            profitMultipleComparison: profitMultipleComparison,
            sizeComparison: sizeComparison,
            growthComparison: growthComparison,
            riskLevel: benchmark.riskLevel
        )
    }
}

struct BenchmarkAnalysis {
    let industry: String
    let revenueMultipleComparison: Double
    let profitMultipleComparison: Double
    let sizeComparison: Double
    let growthComparison: Double
    let riskLevel: RiskLevel
    
    var overallScore: Double {
        let revenueScore = max(0, 1 - abs(revenueMultipleComparison - 1))
        let profitScore = max(0, 1 - abs(profitMultipleComparison - 1))
        let sizeScore = min(1, sizeComparison)
        let growthScore = growthComparison
        
        return (revenueScore + profitScore + sizeScore + growthScore) / 4
    }
    
    var recommendation: String {
        let score = overallScore
        
        if score >= 0.8 {
            return "Excellent opportunity - above industry standards"
        } else if score >= 0.6 {
            return "Good opportunity - meets industry standards"
        } else if score >= 0.4 {
            return "Fair opportunity - below industry standards"
        } else {
            return "Poor opportunity - significantly below industry standards"
        }
    }
}
