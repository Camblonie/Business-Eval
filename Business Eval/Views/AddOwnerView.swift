//
//  AddOwnerView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/29/25.
//

import SwiftUI
import SwiftData

struct AddOwnerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var title = ""
    @State private var notes = ""
    @State private var contactPreference: ContactPreference = .email
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Information Section
                Section("Basic Information") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.words)
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
                
                // Notes Section
                Section("Notes") {
                    TextField("Additional notes about this owner...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Owner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        addOwner()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addOwner() {
        let owner = Owner(
            name: name,
            email: email.isEmpty ? nil : email,
            phone: phone.isEmpty ? nil : phone,
            title: title.isEmpty ? nil : title,
            notes: notes.isEmpty ? nil : notes
        )
        owner.contactPreference = contactPreference
        
        modelContext.insert(owner)
        dismiss()
    }
}

struct EditOwnerView: View {
    @Bindable var owner: Owner
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Information Section
                Section("Basic Information") {
                    TextField("Name", text: $owner.name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Title", text: binding(for: owner.title))
                        .textInputAutocapitalization(.words)
                }
                
                // Contact Information Section
                Section("Contact Information") {
                    TextField("Email", text: binding(for: owner.email))
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                    
                    TextField("Phone", text: binding(for: owner.phone))
                        .keyboardType(.phonePad)
                    
                    Picker("Contact Preference", selection: $owner.contactPreference) {
                        ForEach(ContactPreference.allCases, id: \.self) { preference in
                            Text(preference.rawValue).tag(preference)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Notes Section
                Section("Notes") {
                    TextField("Additional notes about this owner...", text: binding(for: owner.notes), axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Owner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        owner.updatedAt = Date()
                        dismiss()
                    }
                    .disabled(owner.name.isEmpty)
                }
            }
        }
    }
    
    // Helper function to create bindings for optional strings
    private func binding(for optional: String?) -> Binding<String> {
        Binding(
            get: { optional ?? "" },
            set: { newValue in
                if newValue.isEmpty {
                    // Handle setting to nil based on which property this is
                    if optional == owner.email {
                        owner.email = nil
                    } else if optional == owner.phone {
                        owner.phone = nil
                    } else if optional == owner.title {
                        owner.title = nil
                    } else if optional == owner.notes {
                        owner.notes = nil
                    }
                } else {
                    // Handle setting the value
                    if optional == owner.email {
                        owner.email = newValue
                    } else if optional == owner.phone {
                        owner.phone = newValue
                    } else if optional == owner.title {
                        owner.title = newValue
                    } else if optional == owner.notes {
                        owner.notes = newValue
                    }
                }
            }
        )
    }
}

#Preview {
    AddOwnerView()
        .modelContainer(for: Owner.self, inMemory: true)
}
