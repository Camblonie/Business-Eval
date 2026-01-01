//
//  BrokerBusinessSelectorView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/30/25.
//

import SwiftUI
import SwiftData

struct BrokerBusinessSelectorView: View {
    @Bindable var broker: Broker
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Business.name, order: .forward) private var businesses: [Business]
    @State private var searchText = ""
    
    private var filteredBusinesses: [Business] {
        let availableBusinesses = businesses.filter { !broker.businesses.contains($0) }
        
        if searchText.isEmpty {
            return availableBusinesses
        } else {
            return availableBusinesses.filter { business in
                business.name.localizedCaseInsensitiveContains(searchText) ||
                business.industry.localizedCaseInsensitiveContains(searchText) ||
                business.location.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Content
                if filteredBusinesses.isEmpty {
                    emptyStateView
                } else {
                    businessList
                }
            }
            .navigationTitle("Associate Business")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search businesses...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            if searchText.isEmpty {
                Text("No available businesses")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("All businesses are already associated with this broker")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("No businesses found")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Try adjusting your search terms")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var businessList: some View {
        List {
            ForEach(filteredBusinesses) { business in
                BrokerBusinessSelectionRow(business: business) {
                    associateBusiness(business)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func associateBusiness(_ business: Business) {
        broker.businesses.append(business)
        business.broker = broker
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to associate business with broker: \(error)")
        }
    }
}

struct BrokerBusinessSelectionRow: View {
    let business: Business
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(business.name)
                    .font(.headline)
                
                Spacer()
                
                Text("$\(business.askingPrice, specifier: "%.0f")")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
            
            HStack {
                Text(business.industry)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(business.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if business.annualRevenue > 0 {
                HStack {
                    Text("Revenue: $\(business.annualRevenue, specifier: "%.0f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if business.annualProfit > 0 {
                        Text("Profit: $\(business.annualProfit, specifier: "%.0f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    BrokerBusinessSelectorView(broker: Broker(name: "Test Broker"))
        .modelContainer(for: [Broker.self, Business.self], inMemory: true)
}
