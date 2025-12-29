//
//  OfferRecommendationView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData

struct OfferRecommendationView: View {
    let business: Business
    @State private var recommendation: OfferRecommendation?
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if isLoading {
                    ProgressView("Generating recommendations...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else if let recommendation = recommendation {
                    // Executive Summary
                    executiveSummarySection(recommendation: recommendation)
                    
                    // Recommended Offer Range
                    offerRangeSection(recommendation: recommendation)
                    
                    // Valuation Analysis
                    valuationAnalysisSection(recommendation: recommendation)
                    
                    // Market Position
                    marketPositionSection(recommendation: recommendation)
                    
                    // Negotiation Strategy
                    negotiationStrategySection(recommendation: recommendation)
                    
                    // Risk Factors
                    riskFactorsSection(recommendation: recommendation)
                    
                    // Next Steps
                    nextStepsSection(recommendation: recommendation)
                }
            }
            .padding()
        }
        .navigationTitle("Offer Recommendation")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            generateRecommendation()
        }
    }
    
    private func executiveSummarySection(recommendation: OfferRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Executive Summary")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(recommendation.executiveSummary)
                    .font(.body)
                
                HStack {
                    Text("Confidence Level:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(recommendation.confidenceLevel.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(confidenceColor(recommendation.confidenceLevel).opacity(0.2))
                        .foregroundColor(confidenceColor(recommendation.confidenceLevel))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func offerRangeSection(recommendation: OfferRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended Offer Range")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                // Offer range visual
                VStack(spacing: 8) {
                    HStack {
                        Text("$\(recommendation.minimumOffer, specifier: "%.0f")")
                            .font(.caption)
                            .foregroundColor(.red)
                        
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [.red, .orange, .green, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(height: 12)
                            .cornerRadius(6)
                        
                        Text("$\(recommendation.maximumOffer, specifier: "%.0f")")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    // Markers
                    HStack {
                        Text("Min")
                            .font(.caption2)
                            .foregroundColor(.red)
                        
                        Spacer()
                        
                        Text("Target")
                            .font(.caption2)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        Text("Max")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
                
                // Specific amounts
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    OfferAmountCard(
                        title: "Minimum Offer",
                        amount: recommendation.minimumOffer,
                        description: "Lowest reasonable offer",
                        color: .red
                    )
                    
                    OfferAmountCard(
                        title: "Target Offer",
                        amount: recommendation.recommendedOffer,
                        description: "Optimal offer price",
                        color: .green
                    )
                    
                    OfferAmountCard(
                        title: "Maximum Offer",
                        amount: recommendation.maximumOffer,
                        description: "Highest reasonable offer",
                        color: .blue
                    )
                    
                    OfferAmountCard(
                        title: "Asking Price",
                        amount: business.askingPrice,
                        description: "Current asking price",
                        color: .gray
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func valuationAnalysisSection(recommendation: OfferRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Valuation Analysis")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                AnalysisRow(
                    title: "Average Valuation",
                    value: "$\(String(format: "%.0f", recommendation.averageValuation))",
                    context: "Based on all valuations"
                )
                
                AnalysisRow(
                    title: "Valuation Range",
                    value: "$\(recommendation.valuationRange.lowerBound, specifier: "%.0f") - $\(recommendation.valuationRange.upperBound, specifier: "%.0f")",
                    context: "Min to max valuations"
                )
                
                AnalysisRow(
                    title: "Discount to Asking",
                    value: "\(String(format: "%.1f", recommendation.discountToAsking * 100))%",
                    context: "Recommended offer vs asking price"
                )
                
                AnalysisRow(
                    title: "Industry Comparison",
                    value: recommendation.industryComparison,
                    context: "vs industry benchmarks"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func marketPositionSection(recommendation: OfferRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Market Position")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                // Market position indicator
                VStack(spacing: 8) {
                    Text("Competitive Position")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Text("Weak")
                            .font(.caption)
                            .foregroundColor(.red)
                        
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [.red, .orange, .yellow, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Text("Strong")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    // Position marker
                    HStack {
                        Spacer()
                            .frame(width: CGFloat(recommendation.marketPositionScore) * 200)
                        
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 16, height: 16)
                        
                        Spacer()
                            .frame(width: (1.0 - CGFloat(recommendation.marketPositionScore)) * 200)
                    }
                }
                
                // Market factors
                VStack(alignment: .leading, spacing: 8) {
                    Text("Market Factors")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ForEach(recommendation.marketFactors, id: \.self) { factor in
                        HStack {
                            Image(systemName: factor.isPositive ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(factor.isPositive ? .green : .red)
                                .font(.caption)
                            
                            Text(factor.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func negotiationStrategySection(recommendation: OfferRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Negotiation Strategy")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                // Opening position
                VStack(alignment: .leading, spacing: 8) {
                    Text("Opening Position")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("Start at $\(recommendation.openingOffer, specifier: "%.0f")")
                        .font(.body)
                        .foregroundColor(.blue)
                    
                    Text(recommendation.openingStrategy)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Key talking points
                VStack(alignment: .leading, spacing: 8) {
                    Text("Key Talking Points")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ForEach(recommendation.keyTalkingPoints, id: \.self) { point in
                        HStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 6, height: 6)
                            
                            Text(point)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Concession strategy
                VStack(alignment: .leading, spacing: 8) {
                    Text("Concession Strategy")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(recommendation.concessionStrategy)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func riskFactorsSection(recommendation: OfferRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Risk Factors")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                ForEach(recommendation.riskFactors, id: \.self) { risk in
                    RiskFactorCard(risk: risk)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func nextStepsSection(recommendation: OfferRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended Next Steps")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                ForEach(recommendation.nextSteps, id: \.self) { step in
                    HStack {
                        Text("\(step.order).")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        
                        Text(step.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // Helper functions
    private func generateRecommendation() {
        let service = OfferRecommendationService()
        recommendation = service.generateRecommendation(for: business)
        isLoading = false
    }
    
    private func confidenceColor(_ level: ConfidenceLevel) -> Color {
        switch level {
        case .low: return .red
        case .medium: return .orange
        case .high: return .green
        case .veryHigh: return .blue
        }
    }
}

struct OfferAmountCard: View {
    let title: String
    let amount: Double
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("$\(amount, specifier: "%.0f")")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct AnalysisRow: View {
    let title: String
    let value: String
    let context: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(value)
                .font(.body)
                .foregroundColor(.blue)
            
            Text(context)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct RiskFactorCard: View {
    let risk: RiskFactor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(risk.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(risk.severity.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(severityColor(risk.severity).opacity(0.2))
                    .foregroundColor(severityColor(risk.severity))
                    .cornerRadius(6)
            }
            
            Text(risk.description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if !risk.mitigation.isEmpty {
                Text("Mitigation: \(risk.mitigation)")
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .italic()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    private func severityColor(_ severity: RiskSeverity) -> Color {
        switch severity {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        case .critical: return .red
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
    
    return OfferRecommendationView(business: business)
}
