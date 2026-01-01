//
//  CorrespondenceDetailView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/29/25.
//

import SwiftUI
import SwiftData

struct CorrespondenceDetailView: View {
    @Bindable var correspondence: Correspondence
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditCorrespondence = false
    @State private var showingBusinessSelector = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sectionSpacing) {
                // Header Information
                headerSection
                    .fadeIn(delay: 0)
                
                // Business Information - show link option if not linked
                businessLinkSection
                    .fadeIn(delay: 0.05)
                
                // Correspondence Details
                detailsSection
                    .fadeIn(delay: 0.1)
                
                // Content
                contentSection
                    .fadeIn(delay: 0.15)
                
                // Quick Actions
                quickActionsSection
                    .fadeIn(delay: 0.2)
            }
            .padding()
        }
        .navigationTitle(correspondence.subject)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingEditCorrespondence = true }) {
                        Label("Edit Correspondence", systemImage: "pencil")
                    }
                    
                    Button(action: { deleteCorrespondence() }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditCorrespondence) {
            EditCorrespondenceView(correspondence: correspondence)
        }
        .sheet(isPresented: $showingBusinessSelector) {
            CorrespondenceBusinessSelectorView(correspondence: correspondence)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Subject as hero element
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(correspondence.subject)
                        .font(AppTheme.Fonts.title2)
                        .foregroundColor(.white)
                    
                    Text(correspondence.date.formatted(date: .abbreviated, time: .shortened))
                        .font(AppTheme.Fonts.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Type icon
                Image(systemName: typeIcon)
                    .font(.system(size: AppTheme.IconSize.xlarge))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            // Type and direction badges
            HStack(spacing: AppTheme.Spacing.sm) {
                Text(correspondence.type.rawValue)
                    .font(AppTheme.Fonts.captionMedium)
                    .padding(.horizontal, AppTheme.Badge.horizontalPadding)
                    .padding(.vertical, AppTheme.Badge.verticalPadding)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(AppTheme.CornerRadius.medium)
                
                Text(correspondence.direction.rawValue)
                    .font(AppTheme.Fonts.captionMedium)
                    .padding(.horizontal, AppTheme.Badge.horizontalPadding)
                    .padding(.vertical, AppTheme.Badge.verticalPadding)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(AppTheme.CornerRadius.medium)
            }
        }
        .heroCardStyle(gradient: correspondenceGradient)
    }
    
    private var typeIcon: String {
        switch correspondence.type {
        case .email: return "envelope.fill"
        case .phoneCall: return "phone.fill"
        case .textMessage: return "message.fill"
        case .meeting: return "person.2.fill"
        case .letter: return "doc.text.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    private var correspondenceGradient: LinearGradient {
        LinearGradient(
            colors: [typeColor, typeColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Unified section that shows linked business or link option
    private var businessLinkSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            SectionHeader(
                "Linked Business",
                actionTitle: correspondence.business != nil ? "Change" : "Link"
            ) {
                showingBusinessSelector = true
            }
            
            if let business = correspondence.business {
                // Show linked business info
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    ThemedDetailRow(label: "Name", value: business.name)
                    ThemedDivider()
                    ThemedDetailRow(label: "Industry", value: business.industry)
                    ThemedDivider()
                    ThemedDetailRow(label: "Location", value: business.location)
                    ThemedDivider()
                    ThemedDetailRow(label: "Asking Price", value: formatCurrency(business.askingPrice), valueColor: AppTheme.Colors.money)
                }
            } else {
                // Show prompt to link
                Button(action: { showingBusinessSelector = true }) {
                    HStack {
                        Image(systemName: "link.badge.plus")
                            .font(.system(size: AppTheme.IconSize.large))
                            .foregroundColor(AppTheme.Colors.primary)
                        
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Link to a Business")
                                .font(AppTheme.Fonts.subheadlineMedium)
                                .foregroundColor(.primary)
                            
                            Text("Connect this correspondence to a business for better organization")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                    }
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(AppTheme.CornerRadius.medium)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .cardStyle()
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        if amount >= 1_000_000 {
            return String(format: "$%.1fM", amount / 1_000_000)
        } else if amount >= 1_000 {
            return String(format: "$%.0fK", amount / 1_000)
        } else {
            return String(format: "$%.0f", amount)
        }
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Correspondence Details")
                .font(AppTheme.Fonts.headline)
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                ThemedDetailRow(label: "Type", value: correspondence.type.rawValue)
                ThemedDetailRow(label: "Direction", value: correspondence.direction.rawValue)
                ThemedDetailRow(label: "Date", value: correspondence.date.formatted(date: .abbreviated, time: .shortened))
                ThemedDetailRow(label: "Created", value: correspondence.createdAt.formatted(date: .abbreviated, time: .shortened))
            }
        }
        .cardStyle()
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Content")
                .font(AppTheme.Fonts.headline)
            
            Text(correspondence.content)
                .font(AppTheme.Fonts.body)
                .lineSpacing(4)
                .padding()
                .background(AppTheme.Colors.background)
                .cornerRadius(AppTheme.CornerRadius.medium)
        }
        .cardStyle()
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Quick Actions")
                .font(AppTheme.Fonts.headline)
            
            VStack(spacing: AppTheme.Spacing.md) {
                if let business = correspondence.business {
                    ThemedActionButton(
                        title: "View Business: \(business.name)",
                        icon: "building.2",
                        color: AppTheme.Colors.primary
                    ) {
                        // Navigate to business detail
                    }
                }
                
                if correspondence.type == .email {
                    ThemedActionButton(
                        title: "Reply via Email",
                        icon: "envelope",
                        color: AppTheme.Colors.success
                    ) {
                        // Compose email reply
                    }
                }
                
                if correspondence.type == .phoneCall {
                    ThemedActionButton(
                        title: "Call Back",
                        icon: "phone",
                        color: AppTheme.Colors.warning
                    ) {
                        // Initiate phone call
                    }
                }
                
                ThemedActionButton(
                    title: "Edit Correspondence",
                    icon: "pencil",
                    color: .purple
                ) {
                    showingEditCorrespondence = true
                }
            }
        }
        .cardStyle()
    }
    
    private var typeColor: Color {
        switch correspondence.type {
        case .email: return AppTheme.Colors.primary
        case .phoneCall: return AppTheme.Colors.success
        case .textMessage: return .purple
        case .meeting: return AppTheme.Colors.warning
        case .letter: return .gray
        case .other: return AppTheme.Colors.destructive
        }
    }
    
    private func deleteCorrespondence() {
        // Implementation would require model context access
        // For now, just dismiss
        dismiss()
    }
}

struct EditCorrespondenceView: View {
    @Bindable var correspondence: Correspondence
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            Form {
                Section("Correspondence Details") {
                    TextField("Subject", text: $correspondence.subject)
                    
                    Picker("Type", selection: $correspondence.type) {
                        ForEach(CorrespondenceType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Picker("Direction", selection: $correspondence.direction) {
                        ForEach(CorrespondenceDirection.allCases, id: \.self) { direction in
                            Text(direction.rawValue).tag(direction)
                        }
                    }
                    
                    DatePicker("Date & Time", selection: $correspondence.date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Content") {
                    TextEditor(text: $correspondence.content)
                        .frame(minHeight: 150)
                }
                
                if let business = correspondence.business {
                    Section("Business") {
                        Text(business.name)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Correspondence")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                    .disabled(correspondence.subject.isEmpty || correspondence.content.isEmpty)
                }
            }
        }
    }
}

// CorrespondenceDetailRow is now replaced by ThemedDetailRow from Theme.swift

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
    
    let correspondence = Correspondence(
        subject: "Initial Contact",
        content: "This is a test correspondence content for demonstration purposes.",
        type: .email,
        direction: .outbound,
        business: business
    )
    
    return CorrespondenceDetailView(correspondence: correspondence)
        .modelContainer(for: [Correspondence.self, Business.self], inMemory: true)
}
