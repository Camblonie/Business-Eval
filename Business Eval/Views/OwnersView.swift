//
//  OwnersView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData

struct OwnersView: View {
    @Query(sort: \Owner.name, order: .forward) private var owners: [Owner]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(owners) { owner in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(owner.name)
                            .font(.headline)
                        
                        if let email = owner.email {
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let phone = owner.phone {
                            Text(phone)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("\(owner.businesses.count) business(es)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(owner.contactPreference.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Owners")
        }
    }
}

#Preview {
    OwnersView()
        .modelContainer(for: Owner.self, inMemory: true)
}
