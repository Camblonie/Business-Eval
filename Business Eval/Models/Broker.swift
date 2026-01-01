//
//  Broker.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/30/25.
//

import Foundation
import SwiftData

@Model
final class Broker {
    var id: UUID
    var name: String
    var email: String?
    var phone: String?
    var company: String?
    var license: String?
    var commission: Double?
    var notes: String?
    var contactPreference: ContactPreference
    var createdAt: Date
    var updatedAt: Date
    
    // Relationships
    var businesses: [Business] = []
    
    init(name: String, email: String? = nil, phone: String? = nil, 
         company: String? = nil, license: String? = nil, commission: Double? = nil, notes: String? = nil) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.phone = phone
        self.company = company
        self.license = license
        self.commission = commission
        self.notes = notes
        self.contactPreference = .email
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
