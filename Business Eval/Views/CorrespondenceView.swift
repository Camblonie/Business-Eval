//
//  CorrespondenceView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData

struct CorrespondenceView: View {
    @Query(sort: \Correspondence.date, order: .reverse) private var correspondence: [Correspondence]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(correspondence) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(item.subject)
                                .font(.headline)
                            
                            Spacer()
                            
                            Text(item.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(item.business?.name ?? "Unknown Business")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(item.type.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                            
                            Text(item.direction.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(item.direction == .inbound ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                                .foregroundColor(item.direction == .inbound ? .green : .orange)
                                .cornerRadius(4)
                        }
                        
                        if !item.content.isEmpty {
                            Text(item.content)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Correspondence")
        }
    }
}

#Preview {
    CorrespondenceView()
        .modelContainer(for: Correspondence.self, inMemory: true)
}
