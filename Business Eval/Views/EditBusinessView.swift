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
    @Bindable var business: Business
    @Environment(\.dismiss) private var dismiss
    
    // Local state for editing - initialized from business
    @State private var name: String = ""
    @State private var industry: String = ""
    @State private var location: String = ""
    @State private var businessDescription: String = ""
    @State private var listingURL: String = ""
    @State private var notes: String = ""
    @State private var numberOfEmployees: Int = 0
    @State private var yearsEstablished: Int = 0
    @State private var status: BusinessStatus = .new
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Information Section
                Section {
                    TextField("Business Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Industry", text: $industry)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Location", text: $location)
                        .textInputAutocapitalization(.words)
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
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                // Initialize state from business
                name = business.name
                industry = business.industry
                location = business.location
                businessDescription = business.businessDescription
                listingURL = business.listingURL ?? ""
                notes = business.notes ?? ""
                numberOfEmployees = business.numberOfEmployees
                yearsEstablished = business.yearsEstablished
                status = business.status
            }
        }
    }
    
    // Saves all changes to the business model
    private func saveChanges() {
        business.name = name
        business.industry = industry
        business.location = location
        business.businessDescription = businessDescription
        business.listingURL = listingURL.isEmpty ? nil : listingURL
        business.notes = notes.isEmpty ? nil : notes
        business.numberOfEmployees = numberOfEmployees
        business.yearsEstablished = yearsEstablished
        business.status = status
        business.updatedAt = Date()
        
        dismiss()
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
