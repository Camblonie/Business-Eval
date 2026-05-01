//
//  Business.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Business {
    var id: UUID
    var name: String
    var teaser: String?
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
    
    // Real Estate fields
    var realEstateIncluded: Bool = false
    var realEstateValue: Double = 0.0
    var realEstateSquareFeet: Double = 0.0
    var realEstatePricePerSqFt: Double = 0.0
    var realEstateDescription: String?
    var realEstateNotes: String?
    
    // Relationships
    var correspondence: [Correspondence] = []
    var valuations: [Valuation] = []
    
    // Many-to-many relationship with Owner - Business is the source of truth
    @Relationship(inverse: \Owner.businesses)
    var owners: [Owner] = []
    
    // Many-to-many relationship with Broker - Business is the source of truth
    @Relationship(inverse: \Broker.businesses)
    var brokers: [Broker] = []
    
    var images: [BusinessImage] = []
    
    // Thumbnail image reference
    var thumbnailImage: BusinessImage?
    
    // Market status
    var isOnMarket: Bool = true
    
    // MARK: - Display Properties
    
    /// Returns the display name: uses name if available, falls back to teaser, then default
    var displayName: String {
        if !name.isEmpty {
            return name
        } else if let teaser = teaser, !teaser.isEmpty {
            return teaser
        } else {
            return "Unnamed Business"
        }
    }
    
    /// Returns true if the display name is using the teaser as fallback
    var isUsingTeaser: Bool {
        return name.isEmpty && teaser != nil && !(teaser?.isEmpty ?? true)
    }
    
    init(name: String, 
         teaser: String? = nil,
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
        self.teaser = teaser
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
    
    // MARK: - Image Color Extraction
    
    /// Extracts dominant colors from the thumbnail image
    var extractedColors: [Color] {
        guard let thumbnailImage = thumbnailImage,
              let uiImage = thumbnailImage.image else {
            return [AppTheme.Colors.primary, AppTheme.Colors.secondary]
        }
        
        return extractColors(from: uiImage)
    }
    
    /// Primary color for UI elements
    var primaryExtractedColor: Color {
        extractedColors.first ?? AppTheme.Colors.primary
    }
    
    /// Secondary color for UI elements
    var secondaryExtractedColor: Color {
        extractedColors.count > 1 ? extractedColors[1] : AppTheme.Colors.secondary
    }
    
    /// Extracts dominant colors from a UIImage using a simple algorithm
    private func extractColors(from image: UIImage) -> [Color] {
        // Resize image for faster processing
        let size = CGSize(width: 50, height: 50)
        let renderer = UIGraphicsImageRenderer(size: size)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        
        guard let cgImage = resizedImage.cgImage else { return [] }
        let width = cgImage.width
        let height = cgImage.height
        
        // Create color dictionary to count occurrences
        var colorCounts: [String: Int] = [:]
        
        // Sample pixels from the image
        for x in stride(from: 0, to: width, by: 5) {
            for y in stride(from: 0, to: height, by: 5) {
                if let pixelData = cgImage.dataProvider?.data,
                   let data = CFDataGetBytePtr(pixelData) {
                    let bytesPerPixel = 4
                    let pixelInfo = Int((width * y + x) * bytesPerPixel)
                    
                    let red = CGFloat(data[pixelInfo]) / 255.0
                    let green = CGFloat(data[pixelInfo + 1]) / 255.0
                    let blue = CGFloat(data[pixelInfo + 2]) / 255.0
                    let alpha = CGFloat(data[pixelInfo + 3]) / 255.0
                    
                    // Skip transparent or very light/dark pixels
                    guard alpha > 0.5,
                          red > 0.1 && red < 0.9,
                          green > 0.1 && green < 0.9,
                          blue > 0.1 && blue < 0.9 else { continue }
                    
                    // Round colors to reduce variations
                    let roundedR = Double(Int(round(red * 10))) * 0.1
                    let roundedG = Double(Int(round(green * 10))) * 0.1
                    let roundedB = Double(Int(round(blue * 10))) * 0.1
                    
                    let colorKey = "\(roundedR),\(roundedG),\(roundedB)"
                    colorCounts[colorKey, default: 0] += 1
                }
            }
        }
        
        // Sort by frequency and return top colors
        let sortedColors = colorCounts.sorted { $0.value > $1.value }
        let topColors = sortedColors.prefix(3).compactMap { colorKey -> Color? in
            let components = colorKey.key.split(separator: ",").compactMap { Double($0) }
            guard components.count == 3 else { return nil }
            return Color(red: components[0], green: components[1], blue: components[2])
        }
        
        return Array(topColors)
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
