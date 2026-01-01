//
//  FinancialRow.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/30/25.
//

import SwiftUI

// FinancialRow is now replaced by ThemedFinancialRow in Theme.swift
// This file is kept for backward compatibility but delegates to the themed version

struct FinancialRow: View {
    let label: String
    let value: Double
    let color: Color
    let isPercentage: Bool
    
    init(label: String, value: Double, color: Color, isPercentage: Bool = false) {
        self.label = label
        self.value = value
        self.color = color
        self.isPercentage = isPercentage
    }
    
    var body: some View {
        ThemedFinancialRow(label: label, value: value, color: color, isPercentage: isPercentage)
    }
}
