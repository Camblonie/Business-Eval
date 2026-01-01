//
//  AddCorrespondenceView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData

struct AddCorrespondenceView: View {
    let business: Business?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Business.name, order: .forward) private var businesses: [Business]
    
    @State private var subject = ""
    @State private var content = ""
    @State private var type: CorrespondenceType = .email
    @State private var direction: CorrespondenceDirection = .outbound
    @State private var selectedBusiness: Business?
    @State private var correspondenceDate = Date()
    
    private var isFormValid: Bool {
        !subject.isEmpty && !content.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Correspondence Details") {
                    TextField("Subject", text: $subject)
                    
                    Picker("Type", selection: $type) {
                        ForEach(CorrespondenceType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Picker("Direction", selection: $direction) {
                        ForEach(CorrespondenceDirection.allCases, id: \.self) { direction in
                            Text(direction.rawValue).tag(direction)
                        }
                    }
                    
                    DatePicker("Date & Time", selection: $correspondenceDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Content") {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                }
                
                Section("Business") {
                    if let business = business {
                        Text(business.name)
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Select Business", selection: $selectedBusiness) {
                            Text("None").tag(nil as Business?)
                            ForEach(businesses, id: \.id) { business in
                                Text(business.name).tag(business as Business?)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Correspondence")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        addCorrespondence()
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private func addCorrespondence() {
        let targetBusiness = business ?? selectedBusiness
        
        let correspondence = Correspondence(
            subject: subject,
            content: content,
            type: type,
            direction: direction,
            business: targetBusiness,
            date: correspondenceDate
        )
        
        modelContext.insert(correspondence)
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
    
    return AddCorrespondenceView(business: business)
        .modelContainer(for: [Business.self, Correspondence.self], inMemory: true)
}
