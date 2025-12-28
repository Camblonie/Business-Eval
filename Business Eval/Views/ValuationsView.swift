//
//  ValuationsView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData

struct ValuationsView: View {
    @Query(sort: \Valuation.createdAt, order: .reverse) private var valuations: [Valuation]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(valuations) { valuation in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(valuation.business?.name ?? "Unknown Business")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("$\(valuation.calculatedValue, specifier: "%.0f")")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        Text(valuation.methodology.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("Multiple: \(valuation.multiple, specifier: "%.1f")x")
                                .font(.caption)
                            
                            Spacer()
                            
                            Text(valuation.confidenceLevel.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(confidenceColor.opacity(0.2))
                                .foregroundColor(confidenceColor)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Valuations")
        }
    }
    
    private var confidenceColor: Color {
        // This will be used when displaying valuations
        return .blue
    }
}

#Preview {
    ValuationsView()
        .modelContainer(for: Valuation.self, inMemory: true)
}
