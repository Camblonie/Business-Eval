//
//  ROICalculator.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import Foundation

struct ROIResults {
    let totalROI: Double
    let annualROI: Double
    let netProfit: Double
    let paybackPeriod: Double
    let totalInvestment: Double
    let exitValue: Double
    let totalCashFlow: Double
    let irr: Double
    let npv: Double
    let yearlyCashFlows: [Double]
    let cumulativeCashFlows: [Double]
    let investmentRisk: String
    let riskDescription: String
    let riskFactors: [String]
    let lowGrowthROI: Double
    let highGrowthROI: Double
    let lowMarginROI: Double
    let highMarginROI: Double
    let lowExitROI: Double
    let highExitROI: Double
}

class ROICalculator {
    private let discountRate: Double = 0.10 // 10% discount rate for NPV
    
    func calculateROI(
        business: Business,
        purchasePrice: Double,
        investmentPeriod: Int,
        revenueGrowthRate: Double,
        profitMargin: Double,
        exitMultiple: Double,
        additionalInvestment: Double,
        workingCapital: Double
    ) -> ROIResults {
        
        let totalInvestment = purchasePrice + additionalInvestment + workingCapital
        var yearlyCashFlows: [Double] = []
        var cumulativeCashFlows: [Double] = []
        var cumulativeCashFlow: Double = 0
        
        // Calculate yearly cash flows
        for year in 1...investmentPeriod {
            let yearRevenue = business.annualRevenue * pow(1 + revenueGrowthRate, Double(year))
            let yearProfit = yearRevenue * profitMargin
            let cashFlow = yearProfit - (additionalInvestment / Double(investmentPeriod))
            
            yearlyCashFlows.append(cashFlow)
            cumulativeCashFlow += cashFlow
            cumulativeCashFlows.append(cumulativeCashFlow)
        }
        
        // Add exit value in final year
        let exitRevenue = business.annualRevenue * pow(1 + revenueGrowthRate, Double(investmentPeriod))
        let exitProfit = exitRevenue * profitMargin
        let exitValue = exitProfit * exitMultiple
        
        var finalYearCashFlows = yearlyCashFlows
        finalYearCashFlows[investmentPeriod - 1] += exitValue + workingCapital // Add working capital recovery
        
        let totalCashFlow = finalYearCashFlows.reduce(0, +)
        let netProfit = totalCashFlow - totalInvestment
        let totalROI = netProfit / totalInvestment
        let annualROI = pow(1 + totalROI, 1.0 / Double(investmentPeriod)) - 1
        
        // Calculate payback period
        var paybackPeriod: Double = investmentPeriod
        for (index, cumulative) in cumulativeCashFlows.enumerated() {
            if cumulative >= totalInvestment {
                paybackPeriod = Double(index + 1)
                break
            }
        }
        
        // Calculate IRR (simplified)
        let irr = calculateIRR(cashFlows: finalYearCashFlows, initialInvestment: totalInvestment)
        
        // Calculate NPV
        let npv = calculateNPV(cashFlows: finalYearCashFlows, discountRate: discountRate, initialInvestment: totalInvestment)
        
        // Risk assessment
        let (investmentRisk, riskDescription, riskFactors) = assessRisk(
            roi: totalROI,
            paybackPeriod: paybackPeriod,
            volatility: calculateVolatility(cashFlows: yearlyCashFlows)
        )
        
        // Sensitivity analysis
        let lowGrowthROI = calculateSensitivityROI(
            business: business,
            purchasePrice: purchasePrice,
            investmentPeriod: investmentPeriod,
            revenueGrowthRate: revenueGrowthRate * 0.5,
            profitMargin: profitMargin,
            exitMultiple: exitMultiple,
            additionalInvestment: additionalInvestment,
            workingCapital: workingCapital
        )
        
        let highGrowthROI = calculateSensitivityROI(
            business: business,
            purchasePrice: purchasePrice,
            investmentPeriod: investmentPeriod,
            revenueGrowthRate: revenueGrowthRate * 1.5,
            profitMargin: profitMargin,
            exitMultiple: exitMultiple,
            additionalInvestment: additionalInvestment,
            workingCapital: workingCapital
        )
        
        let lowMarginROI = calculateSensitivityROI(
            business: business,
            purchasePrice: purchasePrice,
            investmentPeriod: investmentPeriod,
            revenueGrowthRate: revenueGrowthRate,
            profitMargin: profitMargin * 0.8,
            exitMultiple: exitMultiple,
            additionalInvestment: additionalInvestment.
            workingCapital: workingCapital
        )
        
        let highMarginROI = calculateSensitivityROI(
            business: business,
            purchasePrice: purchasePrice,
            investmentPeriod: investmentPeriod,
            revenueGrowthRate: revenueGrowthRate,
            profitMargin: profitMargin * 1.2,
            exitMultiple: exitMultiple,
            additionalInvestment: additionalInvestment,
            workingCapital: workingCapital
        )
        
        let lowExitROI = calculateSensitivityROI(
            business: business,
            purchasePrice: purchasePrice,
            investmentPeriod: investmentPeriod,
            revenueGrowthRate: revenueGrowthRate,
            profitMargin: profitMargin,
            exitMultiple: exitMultiple * 0.8,
            additionalInvestment: additionalInvestment,
            workingCapital: workingCapital
        )
        
        let highExitROI = calculateSensitivityROI(
            business: business,
            purchasePrice: purchasePrice,
            investmentPeriod: investmentPeriod,
            revenueGrowthRate: revenueGrowthRate,
            profitMargin: profitMargin,
            exitMultiple: exitMultiple * 1.2,
            additionalInvestment: additionalInvestment,
            workingCapital: workingCapital
        )
        
        return ROIResults(
            totalROI: totalROI,
            annualROI: annualROI,
            netProfit: netProfit,
            paybackPeriod: paybackPeriod,
            totalInvestment: totalInvestment,
            exitValue: exitValue,
            totalCashFlow: totalCashFlow,
            irr: irr,
            npv: npv,
            yearlyCashFlows: yearlyCashFlows,
            cumulativeCashFlows: cumulativeCashFlows,
            investmentRisk: investmentRisk,
            riskDescription: riskDescription,
            riskFactors: riskFactors,
            lowGrowthROI: lowGrowthROI,
            highGrowthROI: highGrowthROI,
            lowMarginROI: lowMarginROI,
            highMarginROI: highMarginROI,
            lowExitROI: lowExitROI,
            highExitROI: highExitROI
        )
    }
    
    private func calculateIRR(cashFlows: [Double], initialInvestment: Double) -> Double {
        // Simplified IRR calculation using Newton-Raphson method
        var irr: Double = 0.1 // Initial guess
        let tolerance: Double = 0.0001
        let maxIterations: Int = 100
        
        for _ in 0..<maxIterations {
            var npv: Double = -initialInvestment
            
            for (index, cashFlow) in cashFlows.enumerated() {
                npv += cashFlow / pow(1 + irr, Double(index + 1))
            }
            
            // Calculate derivative
            var derivative: Double = 0
            for (index, cashFlow) in cashFlows.enumerated() {
                derivative -= Double(index + 1) * cashFlow / pow(1 + irr, Double(index + 2))
            }
            
            let newIrr = irr - npv / derivative
            
            if abs(newIrr - irr) < tolerance {
                return newIrr
            }
            
            irr = newIrr
        }
        
        return irr
    }
    
    private func calculateNPV(cashFlows: [Double], discountRate: Double, initialInvestment: Double) -> Double {
        var npv: Double = -initialInvestment
        
        for (index, cashFlow) in cashFlows.enumerated() {
            npv += cashFlow / pow(1 + discountRate, Double(index + 1))
        }
        
        return npv
    }
    
    private func calculateVolatility(cashFlows: [Double]) -> Double {
        guard cashFlows.count > 1 else { return 0 }
        
        let mean = cashFlows.reduce(0, +) / Double(cashFlows.count)
        let variance = cashFlows.reduce(0) { sum, value in
            let diff = value - mean
            return sum + diff * diff
        } / Double(cashFlows.count)
        
        return sqrt(variance) / mean
    }
    
    private func assessRisk(roi: Double, paybackPeriod: Double, volatility: Double) -> (String, String, [String]) {
        var riskLevel: String
        var riskDescription: String
        var riskFactors: [String] = []
        
        // Assess risk level
        if roi > 0.3 && paybackPeriod < 3 && volatility < 0.2 {
            riskLevel = "Low"
            riskDescription = "Low risk investment with strong returns and quick payback"
        } else if roi > 0.15 && paybackPeriod < 5 && volatility < 0.4 {
            riskLevel = "Medium"
            riskDescription = "Moderate risk investment with reasonable returns"
        } else {
            riskLevel = "High"
            riskDescription = "High risk investment with uncertain returns and longer payback"
        }
        
        // Identify risk factors
        if roi < 0.1 {
            riskFactors.append("Low projected ROI")
        }
        
        if paybackPeriod > 5 {
            riskFactors.append("Long payback period")
        }
        
        if volatility > 0.3 {
            riskFactors.append("High cash flow volatility")
        }
        
        if roi < 0 {
            riskFactors.append("Negative projected returns")
        }
        
        if riskFactors.isEmpty {
            riskFactors.append("No significant risk factors identified")
        }
        
        return (riskLevel, riskDescription, riskFactors)
    }
    
    private func calculateSensitivityROI(
        business: Business,
        purchasePrice: Double,
        investmentPeriod: Int,
        revenueGrowthRate: Double,
        profitMargin: Double,
        exitMultiple: Double,
        additionalInvestment: Double,
        workingCapital: Double
    ) -> Double {
        
        let totalInvestment = purchasePrice + additionalInvestment + workingCapital
        var totalCashFlow: Double = 0
        
        for year in 1...investmentPeriod {
            let yearRevenue = business.annualRevenue * pow(1 + revenueGrowthRate, Double(year))
            let yearProfit = yearRevenue * profitMargin
            let cashFlow = yearProfit - (additionalInvestment / Double(investmentPeriod))
            totalCashFlow += cashFlow
        }
        
        // Add exit value
        let exitRevenue = business.annualRevenue * pow(1 + revenueGrowthRate, Double(investmentPeriod))
        let exitProfit = exitRevenue * profitMargin
        let exitValue = exitProfit * exitMultiple
        
        totalCashFlow += exitValue + workingCapital
        
        let netProfit = totalCashFlow - totalInvestment
        return netProfit / totalInvestment
    }
}
