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
         businessDescription: String = "") {
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
        self.status = .new
        self.createdAt = Date()
        self.updatedAt = Date()
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
