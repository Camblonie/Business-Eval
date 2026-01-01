//
//  BrokerAnalyticsView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/30/25.
//

import SwiftUI
import SwiftData

struct BrokerAnalyticsView: View {
    @Query(sort: \Broker.name, order: .forward) private var brokers: [Broker]
    
    private var totalBrokers: Int {
        brokers.count
    }
    
    private var totalBusinessesRepresented: Int {
        brokers.reduce(0) { $0 + $1.businesses.count }
    }
    
    private var averageCommissionRate: Double {
        let brokersWithCommission = brokers.filter { $0.commission != nil }
        guard !brokersWithCommission.isEmpty else { return 0 }
        return brokersWithCommission.reduce(0) { $0 + ($1.commission ?? 0) } / Double(brokersWithCommission.count)
    }
    
    private var topBroker: Broker? {
        brokers.max { $0.businesses.count < $1.businesses.count }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overview Stats
                overviewSection
                
                // Top Performers
                if !brokers.isEmpty {
                    topPerformersSection
                }
                
                // Commission Analytics
                commissionSection
            }
            .padding()
        }
        .navigationTitle("Broker Analytics")
    }
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(title: "Total Brokers", value: "\(totalBrokers)", color: .blue)
                StatCard(title: "Businesses Represented", value: "\(totalBusinessesRepresented)", color: .green)
                StatCard(title: "Avg Commission", value: String(format: "%.1f%%", averageCommissionRate), color: .orange)
                StatCard(title: "Avg Businesses/Broker", value: totalBrokers > 0 ? String(format: "%.1f", Double(totalBusinessesRepresented) / Double(totalBrokers)) : "0", color: .purple)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var topPerformersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Performers")
                .font(.headline)
                .fontWeight(.bold)
            
            if let topBroker = topBroker {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Most Businesses")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(topBroker.name)
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        Text("\(topBroker.businesses.count)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var commissionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Commission Analytics")
                .font(.headline)
                .fontWeight(.bold)
            
            let brokersWithCommission = brokers.filter { $0.commission != nil }
            
            if brokersWithCommission.isEmpty {
                Text("No commission data available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(brokersWithCommission.sorted(by: { ($0.commission ?? 0) > ($1.commission ?? 0) }).prefix(5)) { broker in
                        HStack {
                            Text(broker.name)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(broker.commission ?? 0, specifier: "%.1f")%")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    BrokerAnalyticsView()
        .modelContainer(for: Broker.self, inMemory: true)
}
