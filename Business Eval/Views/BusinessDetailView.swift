//
//  BusinessDetailView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData

struct BusinessDetailView: View {
    @Bindable var business: Business
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddCorrespondence = false
    @State private var showingAddValuation = false
    @State private var showingOwnerDetail = false
    @State private var showingAddImages = false
    @State private var showingValuationCalculator = false
    @State private var showingValuationComparison = false
    @State private var showingValuationExport = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Business Overview
                businessOverviewSection
                
                // Financial Summary
                financialSummarySection
                
                // Business Details
                businessDetailsSection
                
                // Business Images
                imagesSection
                
                // Owner Information
                ownerSection
                
                // Correspondence History
                correspondenceSection
                
                // Valuations
                valuationsSection
            }
            .padding()
        }
        .navigationTitle(business.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingAddCorrespondence = true }) {
                        Label("Add Correspondence", systemImage: "envelope")
                    }
                    Button(action: { showingAddValuation = true }) {
                        Label("Add Valuation", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    Button(action: { showingValuationCalculator = true }) {
                        Label("Valuation Calculator", systemImage: "calculator")
                    }
                    if business.valuations.count >= 2 {
                        Button(action: { showingValuationComparison = true }) {
                            Label("Compare Valuations", systemImage: "chart.bar.doc.horizontal")
                        }
                    }
                    if business.valuations.count >= 1 {
                        Button(action: { showingValuationExport = true }) {
                            Label("Export Valuations", systemImage: "square.and.arrow.up")
                        }
                    }
                    Button(action: { showingAddImages = true }) {
                        Label("Add Images", systemImage: "photo")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showingAddCorrespondence) {
            AddCorrespondenceView(business: business)
        }
        .sheet(isPresented: $showingAddValuation) {
            AddValuationView(business: business)
        }
        .sheet(isPresented: $showingValuationCalculator) {
            ValuationCalculatorView(business: business)
        }
        .sheet(isPresented: $showingValuationComparison) {
            ValuationComparisonView(business: business)
        }
        .sheet(isPresented: $showingValuationExport) {
            ValuationExportView(business: business)
        }
        .sheet(isPresented: $showingAddImages) {
            AddBusinessImageView(business: business)
        }
        .sheet(isPresented: $showingOwnerDetail) {
            if let owner = business.owner {
                OwnerDetailView(owner: owner)
            }
        }
    }
    
    private var businessOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(business.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(business.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(12)
            }
            
            Text(business.industry)
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack {
                Label(business.location, systemImage: "location")
                Spacer()
                Label("\(business.yearsEstablished) years", systemImage: "calendar")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            if !business.businessDescription.isEmpty {
                Text(business.businessDescription)
                    .font(.body)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var financialSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Financial Summary")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                FinancialRow(label: "Asking Price", value: business.askingPrice, color: .green)
                FinancialRow(label: "Annual Revenue", value: business.annualRevenue, color: .blue)
                FinancialRow(label: "Annual Profit", value: business.annualProfit, color: .purple)
                
                if business.annualRevenue > 0 {
                    let profitMargin = (business.annualProfit / business.annualRevenue) * 100
                    FinancialRow(label: "Profit Margin", value: profitMargin, color: .orange, isPercentage: true)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var businessDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Business Details")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                DetailRow(label: "Employees", value: "\(business.numberOfEmployees)")
                DetailRow(label: "Years Established", value: "\(business.yearsEstablished)")
                
                if let listingURL = business.listingURL, !listingURL.isEmpty {
                    DetailRow(label: "Listing", value: listingURL, isURL: true)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var imagesSection: some View {
        BusinessImagesView(business: business)
    }
    
    private var ownerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Owner Information")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                if business.owner != nil {
                    Button("View Details") {
                        showingOwnerDetail = true
                    }
                    .font(.caption)
                } else {
                    Button("Add Owner") {
                        // TODO: Implement Add Owner functionality
                    }
                    .font(.caption)
                }
            }
            
            if let owner = business.owner {
                VStack(alignment: .leading, spacing: 4) {
                    Text(owner.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if let email = owner.email {
                        Text(email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let phone = owner.phone {
                        Text(phone)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                Text("No owner information available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var correspondenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Correspondence History")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(business.correspondence.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            if business.correspondence.isEmpty {
                Text("No correspondence recorded")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(business.correspondence.sorted(by: { $0.date > $1.date }).prefix(3)) { correspondence in
                    CorrespondenceRowView(correspondence: correspondence)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var valuationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Valuations")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(business.valuations.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(8)
            }
            
            if business.valuations.isEmpty {
                Text("No valuations performed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(business.valuations.sorted(by: { $0.createdAt > $1.createdAt }).prefix(3)) { valuation in
                    ValuationRowView(valuation: valuation)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var statusColor: Color {
        switch business.status {
        case .new: return .blue
        case .researching: return .orange
        case .contacted: return .purple
        case .underReview: return .yellow
        case .offerMade: return .green
        case .negotiating: return .red
        case .dueDiligence: return .indigo
        case .closed: return .primary
        case .rejected: return .red
        case .notInterested: return .gray
        }
    }
}

struct FinancialRow: View {
    let label: String
    let value: Double
    let color: Color
    let isPercentage: Bool
    
    init(label: String, value: Double, color: Color, isPercentage: Bool = false) {
        self.label = label
        self.value = value
        self.color = color
        self.isPercentage = isPercentage
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            
            Spacer()
            
            Text(isPercentage ? String(format: "%.1f%%", value) : String(format: "$%.0f", value))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    let isURL: Bool
    
    init(label: String, value: String, isURL: Bool = false) {
        self.label = label
        self.value = value
        self.isURL = isURL
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            
            Spacer()
            
            if isURL {
                Link("View Listing", destination: URL(string: value)!)
                    .font(.caption)
                    .foregroundColor(.blue)
            } else {
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CorrespondenceRowView: View {
    let correspondence: Correspondence
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(correspondence.subject)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(correspondence.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(correspondence.type.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
                
                Text(correspondence.direction.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(correspondence.direction == .inbound ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                    .foregroundColor(correspondence.direction == .inbound ? .green : .orange)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ValuationRowView: View {
    let valuation: Valuation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(valuation.methodology.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("$\(valuation.calculatedValue, specifier: "%.0f")")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Multiple: \(valuation.multiple, specifier: "%.1f")x")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(valuation.confidenceLevel.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(confidenceColor.opacity(0.2))
                    .foregroundColor(confidenceColor)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var confidenceColor: Color {
        switch valuation.confidenceLevel {
        case .low: return .red
        case .medium: return .orange
        case .high: return .green
        case .veryHigh: return .blue
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
    
    return BusinessDetailView(business: business)
        .modelContainer(for: Business.self, inMemory: true)
}
