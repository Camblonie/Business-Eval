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
    @State private var showingIndustryBenchmarks = false
    @State private var showingValuationScenarios = false
    @State private var showingROIAnalysis = false
    @State private var showingOfferRecommendation = false
    @State private var showingOwnerSelector = false
    @State private var showingEditFinancialSummary = false
    @State private var showingBrokerSelector = false
    @State private var showingBrokerDetail = false
    @State private var showingEditBusiness = false
    @State private var showingLinkCorrespondence = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sectionSpacing) {
                // Business Overview - appears first with no delay
                businessOverviewSection
                    .fadeIn(delay: 0)
                
                // Financial Summary - staggered appearance
                financialSummarySection
                    .fadeIn(delay: 0.05)
                
                // Business Details
                businessDetailsSection
                    .fadeIn(delay: 0.1)
                
                // Business Images
                imagesSection
                    .fadeIn(delay: 0.15)
                
                // Owner Information
                ownerSection
                    .fadeIn(delay: 0.2)
                
                // Broker Information
                brokerSection
                    .fadeIn(delay: 0.25)
                
                // Notes
                if let notes = business.notes, !notes.isEmpty {
                    notesSection
                        .fadeIn(delay: 0.3)
                }
                
                // Correspondence History
                correspondenceSection
                    .fadeIn(delay: 0.35)
                
                // Valuations
                valuationsSection
                    .fadeIn(delay: 0.4)
            }
            .padding()
        }
        // Display the business name, falling back to the teaser if the name is empty
        .navigationTitle(business.displayName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: AppTheme.Spacing.md) {
                    // Edit button
                    Button(action: { showingEditBusiness = true }) {
                        Image(systemName: "pencil.circle.fill")
                    }
                    
                    // Actions menu
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
                        Button(action: { showingIndustryBenchmarks = true }) {
                            Label("Industry Benchmarks", systemImage: "building.2")
                        }
                        Button(action: { showingValuationScenarios = true }) {
                            Label("Valuation Scenarios", systemImage: "waveform.path.ecg")
                        }
                        Button(action: { showingROIAnalysis = true }) {
                            Label("ROI Analysis", systemImage: "chart.line.uptrend.xyaxis.circle")
                        }
                        Button(action: { showingOfferRecommendation = true }) {
                            Label("Offer Recommendation", systemImage: "hand.tap")
                        }
                        Button(action: { showingAddImages = true }) {
                            Label("Add Images", systemImage: "photo")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
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
        .sheet(isPresented: $showingIndustryBenchmarks) {
            IndustryBenchmarksView(business: business)
        }
        .sheet(isPresented: $showingValuationScenarios) {
            ValuationScenariosView(business: business)
        }
        .sheet(isPresented: $showingROIAnalysis) {
            ROIAnalysisView(business: business)
        }
        .sheet(isPresented: $showingOfferRecommendation) {
            OfferRecommendationView(business: business)
        }
        .sheet(isPresented: $showingAddImages) {
            AddBusinessImageView(business: business)
        }
        .sheet(isPresented: $showingOwnerDetail) {
            if !business.owners.isEmpty {
                OwnerDetailView(owner: business.owners.first!)
            }
        }
        .sheet(isPresented: $showingOwnerSelector) {
            BusinessOwnerSelectorView(business: business)
        }
        .sheet(isPresented: $showingEditFinancialSummary) {
            EditFinancialSummaryView(business: business)
        }
        .sheet(isPresented: $showingBrokerSelector) {
            BusinessBrokerSelectorView(business: business)
        }
        .sheet(isPresented: $showingBrokerDetail) {
            if !business.brokers.isEmpty {
                NavigationView {
                    BrokerDetailView(broker: business.brokers.first!)
                }
            }
        }
        .sheet(isPresented: $showingEditBusiness) {
            EditBusinessView(business: business)
        }
        .sheet(isPresented: $showingLinkCorrespondence) {
            BusinessCorrespondenceSelectorView(business: business)
        }
    }
    
    private var businessOverviewSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                // Display the business name, falling back to the teaser if the name is empty
                Text(business.displayName)
                    .font(AppTheme.Fonts.title2)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Use themed status badge component with white text for contrast
                Text(business.status.rawValue)
                    .font(AppTheme.Fonts.captionMedium)
                    .padding(.horizontal, AppTheme.Badge.largeHorizontalPadding)
                    .padding(.vertical, AppTheme.Badge.largeVerticalPadding)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(AppTheme.CornerRadius.large)
            }
            
            Text(business.industry)
                .font(AppTheme.Fonts.headline)
                .foregroundColor(.white.opacity(0.9))
            
            HStack {
                Label(business.location, systemImage: "location")
                Spacer()
                Label("\(business.yearsEstablished) years", systemImage: "calendar")
            }
            .font(AppTheme.Fonts.subheadline)
            .foregroundColor(.white.opacity(0.8))
            
            if !business.businessDescription.isEmpty {
                Text(business.businessDescription)
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, AppTheme.Spacing.xs)
            }
        }
        .heroCardStyle()
    }
    
    private var financialSummarySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("Financial Summary")
                    .font(AppTheme.Fonts.headline)
                
                Spacer()
                
                Button(action: { showingEditFinancialSummary = true }) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(AppTheme.Colors.primary)
                        .font(.system(size: AppTheme.IconSize.medium))
                }
                .buttonStyle(ScaleButtonStyle())
            }
            
            // Metric cards grid for key financials
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.sm) {
                ThemedMetricCard(
                    title: "Asking Price",
                    value: formatCurrency(business.askingPrice),
                    icon: "tag.fill",
                    color: AppTheme.Colors.money
                )
                
                ThemedMetricCard(
                    title: "Annual Revenue",
                    value: formatCurrency(business.annualRevenue),
                    icon: "chart.line.uptrend.xyaxis",
                    color: AppTheme.Colors.revenue
                )
                
                ThemedMetricCard(
                    title: "Annual Profit",
                    value: formatCurrency(business.annualProfit),
                    icon: "dollarsign.circle.fill",
                    color: business.annualProfit < 0 ? AppTheme.Colors.destructive : AppTheme.Colors.profit
                )
                
                if business.annualRevenue > 0 {
                    let profitMargin = (business.annualProfit / business.annualRevenue) * 100
                    ThemedMetricCard(
                        title: "Profit Margin",
                        value: String(format: "%.1f%%", profitMargin),
                        icon: "percent",
                        color: AppTheme.Colors.margin,
                        trend: profitMargin >= 20 ? .up : (profitMargin >= 10 ? .neutral : .down)
                    )
                }
            }
            
            // Business Financing Section
            if business.askingPrice > 0 {
                ThemedDivider()
                
                Text("Business Financing")
                    .font(AppTheme.Fonts.subheadline)
                    .foregroundColor(AppTheme.Colors.secondary)
                
                // Show business-only price when RE is bundled
                if business.realEstateIncluded && business.realEstateIncludedInPrice && business.realEstateValue > 0 {
                    HStack {
                        Text("Business-Only Price")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        Spacer()
                        Text(formatCurrency(business.businessOnlyPrice))
                            .font(AppTheme.Fonts.captionMedium)
                            .foregroundColor(AppTheme.Colors.profit)
                    }
                }
                
                VStack(spacing: AppTheme.Spacing.xs) {
                    HStack {
                        Text("Down Payment")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        Spacer()
                        Text("\(Int(business.downPaymentPercent))% (\(formatCurrency(business.downPaymentAmount)))")
                            .font(AppTheme.Fonts.captionMedium)
                    }
                    
                    HStack {
                        Text("Loan Amount")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        Spacer()
                        Text(formatCurrency(business.loanAmount))
                            .font(AppTheme.Fonts.captionMedium)
                    }
                    
                    HStack {
                        Text("Interest Rate")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        Spacer()
                        Text(String(format: "%.2f%%", business.loanInterestRate))
                            .font(AppTheme.Fonts.captionMedium)
                    }
                    
                    HStack {
                        Text("Loan Term")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        Spacer()
                        Text("\(business.loanTermYears) years")
                            .font(AppTheme.Fonts.captionMedium)
                    }
                }
                
                // Business annual payment card
                if business.annualLoanPayment > 0 {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Annual Payment")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Text(formatCurrency(business.annualLoanPayment))
                                .font(AppTheme.Fonts.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.Colors.warning)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Monthly Payment")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Text(formatCurrency(business.monthlyLoanPayment))
                                .font(AppTheme.Fonts.headline)
                                .foregroundColor(AppTheme.Colors.warning)
                        }
                    }
                    .padding(AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.warning.opacity(0.1))
                    .cornerRadius(AppTheme.CornerRadius.medium)
                }
            }
            
            // Real Estate Section — always shown when RE is part of the deal
            if business.realEstateIncluded {
                ThemedDivider()
                
                Text(business.realEstateIncludedInPrice ? "Real Estate (Included in Price)" : "Real Estate (Separate)")
                    .font(AppTheme.Fonts.subheadline)
                    .foregroundColor(AppTheme.Colors.secondary)
                
                VStack(spacing: AppTheme.Spacing.xs) {
                    HStack {
                        Text("Property Value")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        Spacer()
                        Text(formatCurrency(business.realEstateValue))
                            .font(AppTheme.Fonts.captionMedium)
                            .foregroundColor(AppTheme.Colors.money)
                    }
                    
                    if business.realEstateSquareFeet > 0 {
                        HStack {
                            Text("Square Footage")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Spacer()
                            Text(String(format: "%.0f sq ft", business.realEstateSquareFeet))
                                .font(AppTheme.Fonts.captionMedium)
                        }
                    }
                    
                    if business.realEstatePricePerSqFt > 0 {
                        HStack {
                            Text("Price Per Sq Ft")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Spacer()
                            Text(String(format: "$%.0f/sq ft", business.realEstatePricePerSqFt))
                                .font(AppTheme.Fonts.captionMedium)
                        }
                    }
                    
                    // Lease cost — always shown
                    if business.realEstateLeaseCostPerMonth > 0 {
                        HStack {
                            Text("Lease / Rent")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Spacer()
                            Text("\(formatCurrency(business.realEstateLeaseCostPerMonth))/mo (\(formatCurrency(business.realEstateLeaseCostPerMonth * 12))/yr)")
                                .font(AppTheme.Fonts.captionMedium)
                        }
                    }
                    
                    if let description = business.realEstateDescription, !description.isEmpty {
                        HStack(alignment: .top) {
                            Text("Description")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Spacer()
                            Text(description)
                                .font(AppTheme.Fonts.captionMedium)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                
                // RE financing details
                if business.realEstateValue > 0 {
                    VStack(spacing: AppTheme.Spacing.xs) {
                        HStack {
                            Text("RE Down Payment")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Spacer()
                            Text("\(Int(business.realEstateDownPaymentPercent))% (\(formatCurrency(business.realEstateDownPaymentAmount)))")
                                .font(AppTheme.Fonts.captionMedium)
                        }
                        
                        HStack {
                            Text("RE Loan Amount")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Spacer()
                            Text(formatCurrency(business.realEstateLoanAmount))
                                .font(AppTheme.Fonts.captionMedium)
                        }
                        
                        HStack {
                            Text("RE Interest Rate")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Spacer()
                            Text(String(format: "%.2f%%", business.realEstateInterestRate))
                                .font(AppTheme.Fonts.captionMedium)
                        }
                        
                        HStack {
                            Text("RE Loan Term")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Spacer()
                            Text("\(business.realEstateLoanTermYears) years")
                                .font(AppTheme.Fonts.captionMedium)
                        }
                    }
                    
                    // RE payment card
                    if business.realEstateAnnualLoanPayment > 0 {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("RE Annual Payment")
                                    .font(AppTheme.Fonts.caption)
                                    .foregroundColor(AppTheme.Colors.secondary)
                                Text(formatCurrency(business.realEstateAnnualLoanPayment))
                                    .font(AppTheme.Fonts.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.Colors.warning)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("RE Monthly Payment")
                                    .font(AppTheme.Fonts.caption)
                                    .foregroundColor(AppTheme.Colors.secondary)
                                Text(formatCurrency(business.realEstateMonthlyLoanPayment))
                                    .font(AppTheme.Fonts.captionMedium)
                                    .foregroundColor(AppTheme.Colors.warning)
                            }
                        }
                        .padding(AppTheme.Spacing.sm)
                        .background(AppTheme.Colors.primary.opacity(0.1))
                        .cornerRadius(AppTheme.CornerRadius.medium)
                    }
                }
                
                // Business vs RE price breakdown when bundled
                if business.realEstateIncludedInPrice && business.askingPrice > 0 && business.realEstateValue > 0 {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Business Only Value")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Text(formatCurrency(business.businessOnlyPrice))
                                .font(AppTheme.Fonts.captionMedium)
                                .foregroundColor(AppTheme.Colors.profit)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Real Estate %")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Text(String(format: "%.1f%%", (business.realEstateValue / business.askingPrice) * 100))
                                .font(AppTheme.Fonts.captionMedium)
                        }
                    }
                    .padding(AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(AppTheme.CornerRadius.medium)
                }
                
                // Total acquisition cost when RE is separate
                if !business.realEstateIncludedInPrice && business.realEstateValue > 0 {
                    HStack {
                        Text("Total Acquisition Cost")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        Spacer()
                        Text(formatCurrency(business.totalAcquisitionCost))
                            .font(AppTheme.Fonts.captionMedium)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.Colors.money)
                    }
                    .padding(AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.money.opacity(0.1))
                    .cornerRadius(AppTheme.CornerRadius.medium)
                }
            }
            
            // Combined debt service & cash flow — shown when both business and RE loans exist
            if business.realEstateIncluded && business.realEstateValue > 0 && business.askingPrice > 0 {
                ThemedDivider()
                
                Text("Combined Debt Service")
                    .font(AppTheme.Fonts.subheadline)
                    .foregroundColor(AppTheme.Colors.secondary)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Annual")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        Text(formatCurrency(business.totalAnnualDebtService))
                            .font(AppTheme.Fonts.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.Colors.warning)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total Monthly")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        Text(formatCurrency(business.totalMonthlyDebtService))
                            .font(AppTheme.Fonts.headline)
                            .foregroundColor(AppTheme.Colors.warning)
                    }
                }
                .padding(AppTheme.Spacing.sm)
                .background(AppTheme.Colors.warning.opacity(0.1))
                .cornerRadius(AppTheme.CornerRadius.medium)
                
                // Cash flow after all debt
                if business.annualProfit > 0 {
                    let cashFlowAfterDebt = business.annualProfit - business.totalAnnualDebtService
                    let dscr = business.totalAnnualDebtService > 0 ? business.annualProfit / business.totalAnnualDebtService : 0
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Cash Flow After All Debt")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Text(formatCurrency(cashFlowAfterDebt))
                                .font(AppTheme.Fonts.captionMedium)
                                .foregroundColor(cashFlowAfterDebt >= 0 ? AppTheme.Colors.success : AppTheme.Colors.destructive)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Debt Service Coverage")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                            Text(String(format: "%.2fx", dscr))
                                .font(AppTheme.Fonts.captionMedium)
                                .foregroundColor(dscr >= 1.25 ? AppTheme.Colors.success : (dscr >= 1.0 ? AppTheme.Colors.warning : AppTheme.Colors.destructive))
                        }
                    }
                }
            } else if business.askingPrice > 0 && business.annualProfit > 0 && business.annualLoanPayment > 0 {
                // Simple cash flow when no RE
                let cashFlowAfterDebt = business.annualProfit - business.annualLoanPayment
                let dscr = business.annualProfit / business.annualLoanPayment
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cash Flow After Debt")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        Text(formatCurrency(cashFlowAfterDebt))
                            .font(AppTheme.Fonts.captionMedium)
                            .foregroundColor(cashFlowAfterDebt >= 0 ? AppTheme.Colors.success : AppTheme.Colors.destructive)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Debt Service Coverage")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                        Text(String(format: "%.2fx", dscr))
                            .font(AppTheme.Fonts.captionMedium)
                            .foregroundColor(dscr >= 1.25 ? AppTheme.Colors.success : (dscr >= 1.0 ? AppTheme.Colors.warning : AppTheme.Colors.destructive))
                    }
                }
            }
        }
        .elevatedCardStyle()
    }
    
    /// Formats currency with K/M suffixes for large numbers
    private func formatCurrency(_ amount: Double) -> String {
        if amount >= 1_000_000 {
            return String(format: "$%.1fM", amount / 1_000_000)
        } else if amount >= 1_000 {
            return String(format: "$%.0fK", amount / 1_000)
        } else {
            return String(format: "$%.0f", amount)
        }
    }
    
    private var businessDetailsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Business Details")
                .font(AppTheme.Fonts.headline)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                ThemedDetailRow(label: "Employees", value: "\(business.numberOfEmployees)")
                ThemedDetailRow(label: "Years Established", value: "\(business.yearsEstablished)")
                
                if let listingURL = business.listingURL, !listingURL.isEmpty {
                    ThemedDetailRow(label: "Listing", value: listingURL, isURL: true)
                }
            }
        }
        .cardStyle()
    }
    
    private var imagesSection: some View {
        BusinessImagesView(business: business)
    }
    
    private var ownerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            SectionHeader(
                "Owner Information",
                actionTitle: !business.owners.isEmpty ? "View Details" : "Add Owner"
            ) {
                if !business.owners.isEmpty {
                    showingOwnerDetail = true
                } else {
                    showingOwnerSelector = true
                }
            }
            
            if !business.owners.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    ForEach(business.owners, id: \.id) { owner in
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            HStack {
                                Text(owner.name)
                                    .font(AppTheme.Fonts.subheadlineMedium)
                                
                                if business.owners.count > 1 {
                                    Text("•")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.Colors.secondary)
                                }
                            }
                            
                            if let email = owner.email {
                                Text(email)
                                    .font(AppTheme.Fonts.caption)
                                    .foregroundColor(AppTheme.Colors.secondary)
                            }
                            
                            if let phone = owner.phone {
                                Text(phone)
                                    .font(AppTheme.Fonts.caption)
                                    .foregroundColor(AppTheme.Colors.secondary)
                            }
                        }
                        .padding(.bottom, 4)
                    }
                }
            } else {
                Text("No owner information available")
                    .font(AppTheme.Fonts.subheadline)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
        }
        .cardStyle()
    }
    
    private var brokerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            SectionHeader(
                "Broker Information",
                actionTitle: !business.brokers.isEmpty ? "View Details" : "Add Broker"
            ) {
                if !business.brokers.isEmpty {
                    showingBrokerDetail = true
                } else {
                    showingBrokerSelector = true
                }
            }
            
            if !business.brokers.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    ForEach(business.brokers, id: \.id) { broker in
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            HStack {
                                Text(broker.name)
                                    .font(AppTheme.Fonts.subheadlineMedium)
                                
                                if business.brokers.count > 1 {
                                    Text("•")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.Colors.secondary)
                                }
                            }
                            
                            if let company = broker.company {
                                Text(company)
                                    .font(AppTheme.Fonts.caption)
                                    .foregroundColor(AppTheme.Colors.secondary)
                            }
                            
                            if let email = broker.email {
                                Text(email)
                                    .font(AppTheme.Fonts.caption)
                                    .foregroundColor(AppTheme.Colors.secondary)
                            }
                            
                            if let commission = broker.commission {
                                Text("Commission: \(commission, specifier: "%.1f")%")
                                    .font(AppTheme.Fonts.caption)
                                    .foregroundColor(AppTheme.Colors.secondary)
                            }
                        }
                        .padding(.bottom, 4)
                    }
                }
            } else {
                Text("No broker information available")
                    .font(AppTheme.Fonts.subheadline)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
        }
        .cardStyle()
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            SectionHeader(
                "Notes",
                actionTitle: "Edit"
            ) {
                showingEditBusiness = true
            }
            
            if let notes = business.notes, !notes.isEmpty {
                Text(notes)
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(.primary)
            }
        }
        .cardStyle()
    }
    
    private var correspondenceSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Header with action buttons
            HStack {
                Text("Correspondence History")
                    .font(AppTheme.Fonts.headline)
                
                if !business.correspondence.isEmpty {
                    Text("\(business.correspondence.count)")
                        .font(AppTheme.Fonts.captionMedium)
                        .padding(.horizontal, AppTheme.Badge.horizontalPadding)
                        .padding(.vertical, AppTheme.Badge.verticalPadding)
                        .background(AppTheme.Colors.primary.opacity(0.2))
                        .foregroundColor(AppTheme.Colors.primary)
                        .cornerRadius(AppTheme.CornerRadius.small)
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: AppTheme.Spacing.sm) {
                    Button(action: { showingLinkCorrespondence = true }) {
                        Image(systemName: "link.badge.plus")
                            .font(.system(size: AppTheme.IconSize.small))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    
                    Button(action: { showingAddCorrespondence = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: AppTheme.IconSize.small))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
            }
            
            if business.correspondence.isEmpty {
                Text("No correspondence recorded")
                    .font(AppTheme.Fonts.subheadline)
                    .foregroundColor(AppTheme.Colors.secondary)
            } else {
                ForEach(business.correspondence.sorted(by: { $0.date > $1.date }).prefix(3)) { correspondence in
                    CorrespondenceRowView(correspondence: correspondence)
                }
            }
        }
        .cardStyle()
    }
    
    private var valuationsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            SectionHeader(
                "Valuations",
                count: business.valuations.count,
                countColor: AppTheme.Colors.money
            )
            
            if business.valuations.isEmpty {
                Text("No valuations performed")
                    .font(AppTheme.Fonts.subheadline)
                    .foregroundColor(AppTheme.Colors.secondary)
            } else {
                ForEach(business.valuations.sorted(by: { $0.createdAt > $1.createdAt }).prefix(3)) { valuation in
                    ValuationRowView(valuation: valuation)
                }
            }
        }
        .cardStyle()
    }
}


// DetailRow delegates to ThemedDetailRow from Theme.swift for consistency
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
        ThemedDetailRow(label: label, value: value, isURL: isURL)
    }
}

struct CorrespondenceRowView: View {
    let correspondence: Correspondence
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack {
                Text(correspondence.subject)
                    .font(AppTheme.Fonts.subheadlineMedium)
                
                Spacer()
                
                Text(correspondence.date, style: .date)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
            
            HStack {
                StatusBadge(correspondence.type.rawValue, color: AppTheme.Colors.primary)
                
                StatusBadge(
                    correspondence.direction.rawValue,
                    color: correspondence.direction == .inbound ? AppTheme.Colors.inbound : AppTheme.Colors.outbound
                )
            }
        }
        .padding(.vertical, AppTheme.Spacing.rowVerticalPadding)
    }
}

// ValuationRowView is defined in ValuationsView.swift

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
