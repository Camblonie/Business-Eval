//
//  AddBrokerView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/30/25.
//

import SwiftUI
import SwiftData

struct AddBrokerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var company = ""
    @State private var license = ""
    @State private var commission = ""
    @State private var notes = ""
    @State private var contactPreference: ContactPreference = .email
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Information Section
                Section("Basic Information") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Company", text: $company)
                        .textInputAutocapitalization(.words)
                    
                    TextField("License Number", text: $license)
                }
                
                // Contact Information Section
                Section("Contact Information") {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                    
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    
                    Picker("Contact Preference", selection: $contactPreference) {
                        ForEach(ContactPreference.allCases, id: \.self) { preference in
                            Text(preference.rawValue).tag(preference)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Commission Section
                Section("Commission Information") {
                    HStack {
                        Text("Commission Rate")
                        Spacer()
                        TextField("0.0", text: $commission)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                        Text("%")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Notes Section
                Section("Notes") {
                    TextField("Additional notes about this broker...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Broker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        addBroker()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addBroker() {
        let broker = Broker(
            name: name,
            email: email.isEmpty ? nil : email,
            phone: phone.isEmpty ? nil : phone,
            company: company.isEmpty ? nil : company,
            license: license.isEmpty ? nil : license,
            commission: Double(commission),
            notes: notes.isEmpty ? nil : notes
        )
        broker.contactPreference = contactPreference
        
        modelContext.insert(broker)
        dismiss()
    }
}

struct EditBrokerView: View {
    @Bindable var broker: Broker
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Information Section
                Section("Basic Information") {
                    TextField("Name", text: $broker.name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Company", text: companyBinding)
                        .textInputAutocapitalization(.words)
                    
                    TextField("License Number", text: licenseBinding)
                }
                
                // Contact Information Section
                Section("Contact Information") {
                    TextField("Email", text: emailBinding)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                    
                    TextField("Phone", text: phoneBinding)
                        .keyboardType(.phonePad)
                    
                    Picker("Contact Preference", selection: $broker.contactPreference) {
                        ForEach(ContactPreference.allCases, id: \.self) { preference in
                            Text(preference.rawValue).tag(preference)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Commission Section
                Section("Commission Information") {
                    HStack {
                        Text("Commission Rate")
                        Spacer()
                        TextField("0.0", text: commissionBinding)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                        Text("%")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Notes Section
                Section("Notes") {
                    TextField("Additional notes about this broker...", text: notesBinding, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Broker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        broker.updatedAt = Date()
                        dismiss()
                    }
                    .disabled(broker.name.isEmpty)
                }
            }
        }
    }
    
    // Independent binding for email
    private var emailBinding: Binding<String> {
        Binding(
            get: { broker.email ?? "" },
            set: { newValue in
                broker.email = newValue.isEmpty ? nil : newValue
            }
        )
    }
    
    // Independent binding for phone
    private var phoneBinding: Binding<String> {
        Binding(
            get: { broker.phone ?? "" },
            set: { newValue in
                broker.phone = newValue.isEmpty ? nil : newValue
            }
        )
    }
    
    // Independent binding for company
    private var companyBinding: Binding<String> {
        Binding(
            get: { broker.company ?? "" },
            set: { newValue in
                broker.company = newValue.isEmpty ? nil : newValue
            }
        )
    }
    
    // Independent binding for license
    private var licenseBinding: Binding<String> {
        Binding(
            get: { broker.license ?? "" },
            set: { newValue in
                broker.license = newValue.isEmpty ? nil : newValue
            }
        )
    }
    
    // Independent binding for commission
    private var commissionBinding: Binding<String> {
        Binding(
            get: { broker.commission != nil ? String(broker.commission!) : "" },
            set: { newValue in
                broker.commission = newValue.isEmpty ? nil : Double(newValue)
            }
        )
    }
    
    // Independent binding for notes
    private var notesBinding: Binding<String> {
        Binding(
            get: { broker.notes ?? "" },
            set: { newValue in
                broker.notes = newValue.isEmpty ? nil : newValue
            }
        )
    }
}

#Preview {
    AddBrokerView()
        .modelContainer(for: Broker.self, inMemory: true)
}
