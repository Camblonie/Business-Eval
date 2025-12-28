//
//  Owner.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import Foundation
import SwiftData

@Model
final class Owner {
    var id: UUID
    var name: String
    var email: String?
    var phone: String?
    var title: String?
    var notes: String?
    var contactPreference: ContactPreference
    var createdAt: Date
    var updatedAt: Date
    
    // Relationships
    @Relationship(deleteRule: .nullify, inverse: \Business.owner)
    var businesses: [Business] = []
    
    init(name: String, email: String? = nil, phone: String? = nil, 
         title: String? = nil, notes: String? = nil) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.phone = phone
        self.title = title
        self.notes = notes
        self.contactPreference = .email
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum ContactPreference: String, CaseIterable, Codable {
    case email = "Email"
    case phone = "Phone"
    case text = "Text"
    case either = "Either"
}
