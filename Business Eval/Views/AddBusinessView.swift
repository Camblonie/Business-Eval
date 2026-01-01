//
//  AddBusinessView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData

struct AddBusinessView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var industry = ""
    @State private var location = ""
    @State private var askingPrice = ""
    @State private var annualRevenue = ""
    @State private var annualProfit = ""
    @State private var numberOfEmployees = ""
    @State private var yearsEstablished = ""
    @State private var businessDescription = ""
    @State private var listingURL = ""
    
        
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Business Name *", text: $name)
                    TextField("Industry (optional)", text: $industry)
                    TextField("Location (optional)", text: $location)
                    TextField("Business Description (optional)", text: $businessDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Financial Information (optional)") {
                    TextField("Asking Price", text: $askingPrice)
                        .keyboardType(.decimalPad)
                    TextField("Annual Revenue", text: $annualRevenue)
                        .keyboardType(.decimalPad)
                    TextField("Annual Profit", text: $annualProfit)
                        .keyboardType(.decimalPad)
                }
                
                Section("Business Details (optional)") {
                    TextField("Number of Employees", text: $numberOfEmployees)
                        .keyboardType(.numberPad)
                    TextField("Years Established", text: $yearsEstablished)
                        .keyboardType(.numberPad)
                    TextField("Listing URL", text: $listingURL)
                        .keyboardType(.URL)
                }
            }
            .navigationTitle("Add Business")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        addBusiness()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addBusiness() {
        let business = Business(
            name: name,
            industry: industry.isEmpty ? "" : industry,
            location: location.isEmpty ? "" : location,
            askingPrice: Double(askingPrice) ?? 0,
            annualRevenue: Double(annualRevenue) ?? 0,
            annualProfit: Double(annualProfit) ?? 0,
            numberOfEmployees: Int(numberOfEmployees) ?? 0,
            yearsEstablished: Int(yearsEstablished) ?? 0,
            businessDescription: businessDescription.isEmpty ? "" : businessDescription
        )
        
        if !listingURL.isEmpty {
            business.listingURL = listingURL
        }
        
        modelContext.insert(business)
    }
}

#Preview {
    AddBusinessView()
        .modelContainer(for: Business.self, inMemory: true)
}
