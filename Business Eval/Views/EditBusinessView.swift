//
//  EditBusinessView.swift
//  Business Eval
//
//  Created by Scott Campbell on 1/1/26.
//
//  Allows editing all business information including name, details, and notes.
//

import SwiftUI
import SwiftData

struct EditBusinessView: View {
    let business: Business
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Local state for editing - initialized from business
    @State private var name: String = ""
    @State private var teaser: String = ""
    @State private var industry: String = ""
    @State private var location: String = ""
    @State private var businessDescription: String = ""
    @State private var listingURL: String = ""
    @State private var notes: String = ""
    @State private var numberOfEmployees: Int = 0
    @State private var yearsEstablished: Int = 0
    @State private var status: BusinessStatus = .new
    @State private var isOnMarket: Bool = true
    
    // Calder Lead indicator
    @State private var isCalderLead: Bool = false
    
    // Building details
    @State private var buildingSquareFootage: Double = 0.0
    @State private var buildingOwnershipType: BuildingOwnershipType = BuildingOwnershipType.unknown
    @State private var buildingLeaseCostPerMonth: Double = 0.0
    @State private var buildingValue: Double = 0.0
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Information Section
                Section {
                    TextField("Business Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Teaser", text: $teaser)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Industry", text: $industry)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Location", text: $location)
                        .textInputAutocapitalization(.words)
                    
                    // Market Status Slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Market Status")
                                .font(.headline)
                            Spacer()
                            Text(isOnMarket ? "On Market" : "Off Market")
                                .font(.headline)
                                .foregroundColor(isOnMarket ? .green : .red)
                        }
                        
                        Toggle(isOn: $isOnMarket, label: {
                            Text(isOnMarket ? "Available for purchase" : "No longer available")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        })
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Basic Information")
                } footer: {
                    Text("Enter the core details about this business.")
                }
                
                // Status Section
                Section("Status") {
                    Picker("Business Status", selection: $status) {
                        ForEach(BusinessStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Toggle("Calder Lead", isOn: $isCalderLead)
                }
                
                // Business Details Section
                Section {
                    Stepper("Employees: \(numberOfEmployees)", value: $numberOfEmployees, in: 0...10000)
                    
                    Stepper("Years Established: \(yearsEstablished)", value: $yearsEstablished, in: 0...200)
                    
                    TextField("Listing URL", text: $listingURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                } header: {
                    Text("Business Details")
                }
                
                // Building Details Section
                Section {
                    TextField("Building Square Footage", value: $buildingSquareFootage, format: .number)
                        .keyboardType(.decimalPad)
                    
                    Picker("Building Ownership", selection: $buildingOwnershipType) {
                        ForEach(BuildingOwnershipType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    if buildingOwnershipType == .leased {
                        TextField("Lease Cost Per Month", value: $buildingLeaseCostPerMonth, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                    }
                    
                    if buildingOwnershipType == .owned {
                        TextField("Building Value", value: $buildingValue, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                    }
                } header: {
                    Text("Building Details")
                }
                
                // Description Section
                Section {
                    TextField("Describe the business...", text: $businessDescription, axis: .vertical)
                        .lineLimit(4...8)
                } header: {
                    Text("Description")
                } footer: {
                    Text("This is typically the description from the listing.")
                }
                
                // Notes Section
                Section {
                    TextField("Your personal notes about this business...", text: $notes, axis: .vertical)
                        .lineLimit(4...10)
                } header: {
                    Text("Notes")
                } footer: {
                    Text("Add your own observations, questions, or reminders about this business.")
                }
            }
            .navigationTitle("Edit Business")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty && teaser.isEmpty)
                }
            }
            .onAppear {
                // Initialize state from business
                name = business.name
                teaser = business.teaser ?? ""
                industry = business.industry
                location = business.location
                businessDescription = business.businessDescription
                listingURL = business.listingURL ?? ""
                notes = business.notes ?? ""
                numberOfEmployees = business.numberOfEmployees
                yearsEstablished = business.yearsEstablished
                status = business.status
                isOnMarket = business.isOnMarket
                isCalderLead = business.isCalderLead
                buildingSquareFootage = business.buildingSquareFootage
                buildingOwnershipType = business.buildingOwnershipType
                buildingLeaseCostPerMonth = business.buildingLeaseCostPerMonth
                buildingValue = business.buildingValue
            }
        }
    }
    
    // Saves all changes to the business model
    private func saveChanges() {
        // Validate that either name or teaser is provided
        guard !name.isEmpty || !teaser.isEmpty else {
            return
        }
        
        business.name = name
        business.teaser = teaser.isEmpty ? nil : teaser
        business.industry = industry
        business.location = location
        business.businessDescription = businessDescription
        business.listingURL = listingURL.isEmpty ? nil : listingURL
        business.notes = notes.isEmpty ? nil : notes
        business.numberOfEmployees = numberOfEmployees
        business.yearsEstablished = yearsEstablished
        business.status = status
        business.isOnMarket = isOnMarket
        business.isCalderLead = isCalderLead
        business.buildingSquareFootage = buildingSquareFootage
        business.buildingOwnershipType = buildingOwnershipType
        business.buildingLeaseCostPerMonth = buildingLeaseCostPerMonth
        business.buildingValue = buildingValue
        business.updatedAt = Date()
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save business changes: \(error)")
        }
    }
}

#Preview {
    let business = Business(
        name: "Test Business",
        industry: "Technology",
        location: "San Francisco, CA",
        askingPrice: 500000,
        annualRevenue: 1000000,
        annualProfit: 200000,
        numberOfEmployees: 10,
        yearsEstablished: 5,
        businessDescription: "A test business for demonstration purposes."
    )
    
    return EditBusinessView(business: business)
        .modelContainer(for: Business.self, inMemory: true)
}
