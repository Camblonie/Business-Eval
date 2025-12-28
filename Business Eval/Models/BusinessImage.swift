//
//  BusinessImage.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import Foundation
import SwiftData
import UIKit

@Model
final class BusinessImage {
    var id: UUID
    var imageData: Data
    var caption: String?
    var createdAt: Date
    
    // Relationships
    var business: Business?
    
    init(imageData: Data, caption: String? = nil, business: Business? = nil) {
        self.id = UUID()
        self.imageData = imageData
        self.caption = caption
        self.business = business
        self.createdAt = Date()
    }
    
    // Helper property to get UIImage from Data
    var image: UIImage? {
        return UIImage(data: imageData)
    }
}
