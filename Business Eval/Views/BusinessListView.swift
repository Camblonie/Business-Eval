//
//  BusinessListView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData

struct BusinessListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Business.createdAt, order: .reverse) private var businesses: [Business]
    @State private var showingAddBusiness = false
    @State private var searchText = ""
    
    var filteredBusinesses: [Business] {
        if searchText.isEmpty {
            return businesses
        } else {
            return businesses.filter { business in
                business.name.localizedCaseInsensitiveContains(searchText) ||
                business.industry.localizedCaseInsensitiveContains(searchText) ||
                business.location.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredBusinesses) { business in
                    NavigationLink(destination: BusinessDetailView(business: business)) {
                        BusinessRowView(business: business)
                    }
                }
                .onDelete(perform: deleteBusinesses)
            }
            .navigationTitle("Potential Businesses")
            .searchable(text: $searchText, prompt: "Search businesses...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddBusiness = true }) {
                        Label("Add Business", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBusiness) {
                AddBusinessView()
            }
        }
    }
    
    private func deleteBusinesses(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredBusinesses[index])
            }
        }
    }
}

struct BusinessRowView: View {
    let business: Business
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(business.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(business.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
            
            Text(business.industry)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text(business.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Asking: \(business.askingPrice, specifier: "$%.0f")")
                    .font(.caption)
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        switch business.status {
        case .new:
            return .blue
        case .researching:
            return .orange
        case .contacted:
            return .purple
        case .underReview:
            return .yellow
        case .offerMade:
            return .green
        case .negotiating:
            return .red
        case .dueDiligence:
            return .indigo
        case .closed:
            return .primary
        case .rejected:
            return .red
        case .notInterested:
            return .gray
        }
    }
}

#Preview {
    BusinessListView()
        .modelContainer(for: Business.self, inMemory: true)
}
