//
//  AddCorrespondenceView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData

struct AddCorrespondenceView: View {
    let business: Business
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var subject = ""
    @State private var content = ""
    @State private var type: CorrespondenceType = .email
    @State private var direction: CorrespondenceDirection = .outbound
    
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
                }
                
                Section("Content") {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                }
                
                Section("Business") {
                    Text(business.name)
                        .foregroundColor(.secondary)
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
        let correspondence = Correspondence(
            subject: subject,
            content: content,
            type: type,
            direction: direction,
            business: business
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
