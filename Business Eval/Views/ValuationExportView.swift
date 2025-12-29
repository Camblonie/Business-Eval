//
//  ValuationExportView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData
import PDFKit

struct ValuationExportView: View {
    let business: Business
    @Environment(\.dismiss) private var dismiss
    @State private var selectedValuations: Set<UUID> = []
    @State private var includeCharts = true
    @State private var includeAnalysis = true
    @State private var exportFormat: ExportFormat = .pdf
    @State private var isExporting = false
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL?
    
    enum ExportFormat: String, CaseIterable {
        case pdf = "PDF Report"
        case csv = "CSV Data"
        case json = "JSON Data"
    }
    
    private var businessValuations: [Valuation] {
        business.valuations.sorted { $0.createdAt > $1.createdAt }
    }
    
    private var selectedValuationObjects: [Valuation] {
        businessValuations.filter { selectedValuations.contains($0.id) }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Export Format") {
                    Picker("Format", selection: $exportFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Select Valuations") {
                    if businessValuations.isEmpty {
                        Text("No valuations available for export")
                            .foregroundColor(.secondary)
                    } else {
                        Toggle("Select All", isOn: Binding(
                            get: { selectedValuations.count == businessValuations.count },
                            set: { isOn in
                                if isOn {
                                    selectedValuations = Set(businessValuations.map(\.id))
                                } else {
                                    selectedValuations = []
                                }
                            }
                        ))
                        
                        ForEach(businessValuations, id: \.id) { valuation in
                            HStack {
                                Toggle("", isOn: Binding(
                                    get: { selectedValuations.contains(valuation.id) },
                                    set: { isOn in
                                        if isOn {
                                            selectedValuations.insert(valuation.id)
                                        } else {
                                            selectedValuations.remove(valuation.id)
                                        }
                                    }
                                ))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(valuation.methodology.rawValue)
                                        .font(.subheadline)
                                    Text("$\(valuation.calculatedValue, specifier: "%.0f")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                
                if exportFormat == .pdf {
                    Section("PDF Options") {
                        Toggle("Include Charts", isOn: $includeCharts)
                        Toggle("Include Analysis", isOn: $includeAnalysis)
                    }
                }
                
                Section("Export Summary") {
                    HStack {
                        Text("Selected Valuations")
                        Spacer()
                        Text("\(selectedValuations.count)")
                            .foregroundColor(.blue)
                    }
                    
                    if !selectedValuationObjects.isEmpty {
                        let totalValue = selectedValuationObjects.reduce(0) { $0 + $1.calculatedValue }
                        let avgValue = totalValue / Double(selectedValuationObjects.count)
                        
                        HStack {
                            Text("Average Value")
                            Spacer()
                            Text("$\(avgValue, specifier: "%.0f")")
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("Date Range")
                            Spacer()
                            Text(dateRange)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Export Valuations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Export") {
                        exportValuations()
                    }
                    .disabled(selectedValuations.isEmpty || isExporting)
                }
            }
            .overlay(
                isExporting ? ProgressView("Exporting...") : nil
            )
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportedFileURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
        .onAppear {
            // Select all valuations by default
            selectedValuations = Set(businessValuations.map(\.id))
        }
    }
    
    private var dateRange: String {
        guard !selectedValuationObjects.isEmpty else { return "N/A" }
        
        let dates = selectedValuationObjects.map(\.createdAt)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        if dates.count == 1 {
            return formatter.string(from: dates.first!)
        } else {
            let minDate = dates.min()!
            let maxDate = dates.max()!
            return "\(formatter.string(from: minDate)) - \(formatter.string(from: maxDate))"
        }
    }
    
    private func exportValuations() {
        isExporting = true
        
        Task {
            do {
                let url = try await generateExportFile()
                await MainActor.run {
                    self.exportedFileURL = url
                    self.isExporting = false
                    self.showingShareSheet = true
                }
            } catch {
                await MainActor.run {
                    self.isExporting = false
                    // Handle error - could show alert
                }
            }
        }
    }
    
    private func generateExportFile() async throws -> URL {
        switch exportFormat {
        case .pdf:
            return try await generatePDF()
        case .csv:
            return try generateCSV()
        case .json:
            return try generateJSON()
        }
    }
    
    private func generatePDF() async throws -> URL {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        
        let data = pdfRenderer.pdfData { context in
            context.beginPage()
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            
            let title = "Valuation Report - \(business.name)"
            title.draw(at: CGPoint(x: 50, y: 50), withAttributes: attributes)
            
            // Business information
            var yPosition: CGFloat = 100
            let businessInfo = [
                "Industry: \(business.industry)",
                "Location: \(business.location)",
                "Asking Price: $\(String(format: "%.0f", business.askingPrice))",
                "Annual Revenue: $\(String(format: "%.0f", business.annualRevenue))",
                "Annual Profit: $\(String(format: "%.0f", business.annualProfit))"
            ]
            
            for info in businessInfo {
                info.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.black
                ])
                yPosition += 20
            }
            
            // Valuations
            yPosition += 20
            let valuationsTitle = "Valuations (\(selectedValuationObjects.count))"
            valuationsTitle.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                .foregroundColor: UIColor.black
            ])
            yPosition += 30
            
            for valuation in selectedValuationObjects {
                let valuationText = """
                \(valuation.methodology.rawValue): $\(String(format: "%.0f", valuation.calculatedValue))
                Multiple: \(String(format: "%.1f", valuation.multiple))x
                Confidence: \(valuation.confidenceLevel.rawValue)
                Date: \(formatDate(valuation.createdAt))
                """
                
                valuationText.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.black
                ])
                yPosition += 60
            }
            
            if includeAnalysis {
                yPosition += 20
                let analysisTitle = "Analysis Summary"
                analysisTitle.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                    .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                    .foregroundColor: UIColor.black
                ])
                yPosition += 30
                
                let avgValue = selectedValuationObjects.reduce(0) { $0 + $1.calculatedValue } / Double(selectedValuationObjects.count)
                let avgMultiple = selectedValuationObjects.reduce(0) { $0 + $1.multiple } / Double(selectedValuationObjects.count)
                
                let analysisText = """
                Average Valuation: $\(avgValue, specifier: "%.0f")
                Average Multiple: \(avgMultiple, specifier: "%.1f")x
                Value Range: $\(selectedValuationObjects.map(\.calculatedValue).min() ?? 0, specifier: "%.0f") - $\(selectedValuationObjects.map(\.calculatedValue).max() ?? 0, specifier: "%.0f")
                """
                
                analysisText.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.black
                ])
            }
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "\(business.name.replacingOccurrences(of: " ", with: "_"))_Valuations_\(Date().timeIntervalSince1970).pdf"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        try data.write(to: fileURL)
        return fileURL
    }
    
    private func generateCSV() throws -> URL {
        let csvString = generateCSVString()
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "\(business.name.replacingOccurrences(of: " ", with: "_"))_Valuations_\(Date().timeIntervalSince1970).csv"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
    
    private func generateCSVString() -> String {
        var csv = "Business,Methodology,Calculated Value,Multiple,Confidence Level,Created Date\n"
        
        for valuation in selectedValuationObjects {
            csv += "\(business.name),"
            csv += "\(valuation.methodology.rawValue),"
            csv += "\(valuation.calculatedValue),"
            csv += "\(valuation.multiple),"
            csv += "\(valuation.confidenceLevel.rawValue),"
            csv += "\(valuation.createdAt)\n"
        }
        
        return csv
    }
    
    private func generateJSON() throws -> URL {
        let exportData = ValuationExportData(
            business: BusinessExportData(
                name: business.name,
                industry: business.industry,
                location: business.location,
                askingPrice: business.askingPrice,
                annualRevenue: business.annualRevenue,
                annualProfit: business.annualProfit
            ),
            valuations: selectedValuationObjects.map { valuation in
                ValuationItemExportData(
                    id: valuation.id,
                    calculatedValue: valuation.calculatedValue,
                    methodology: valuation.methodology.rawValue,
                    multiple: valuation.multiple,
                    confidenceLevel: valuation.confidenceLevel.rawValue,
                    notes: valuation.notes,
                    createdAt: valuation.createdAt
                )
            },
            exportDate: Date()
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(exportData)
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "\(business.name.replacingOccurrences(of: " ", with: "_"))_Valuations_\(Date().timeIntervalSince1970).json"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        try data.write(to: fileURL)
        return fileURL
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct ValuationExportData: Codable {
    let business: BusinessExportData
    let valuations: [ValuationItemExportData]
    let exportDate: Date
}

struct ValuationItemExportData: Codable {
    let id: UUID
    let calculatedValue: Double
    let methodology: String
    let multiple: Double
    let confidenceLevel: String
    let notes: String?
    let createdAt: Date
}

struct BusinessExportData: Codable {
    let name: String
    let industry: String
    let location: String
    let askingPrice: Double
    let annualRevenue: Double
    let annualProfit: Double
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
    
    return ValuationExportView(business: business)
}
