//
//  Correspondence.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import Foundation
import SwiftData

@Model
final class Correspondence {
    var id: UUID
    var subject: String
    var content: String
    var date: Date
    var type: CorrespondenceType
    var direction: CorrespondenceDirection
    var createdAt: Date
    
    // Relationships
    var business: Business?
    
    init(subject: String, content: String, type: CorrespondenceType, 
         direction: CorrespondenceDirection, business: Business? = nil, date: Date = Date()) {
        self.id = UUID()
        self.subject = subject
        self.content = content
        self.date = date
        self.type = type
        self.direction = direction
        self.business = business
        self.createdAt = Date()
    }
}

enum CorrespondenceType: String, CaseIterable, Codable {
    case email = "Email"
    case phoneCall = "Phone Call"
    case textMessage = "Text Message"
    case meeting = "Meeting"
    case letter = "Letter"
    case other = "Other"
}

enum CorrespondenceDirection: String, CaseIterable, Codable {
    case inbound = "Inbound"
    case outbound = "Outbound"
}
