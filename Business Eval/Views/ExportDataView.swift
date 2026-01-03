//
//  ExportDataView.swift
//  Business Eval
//
//  Created by Scott Campbell on 1/3/26.
//
//  View for exporting all app data to CSV with email option.
//

import SwiftUI
import SwiftData
import MessageUI

struct ExportDataView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Query all data
    @Query(sort: \Business.name) private var businesses: [Business]
    @Query(sort: \Valuation.createdAt, order: .reverse) private var valuations: [Valuation]
    @Query(sort: \Correspondence.date, order: .reverse) private var correspondence: [Correspondence]
    @Query(sort: \Owner.name) private var owners: [Owner]
    @Query(sort: \Broker.name) private var brokers: [Broker]
    
    // Export options
    @State private var exportType: ExportType = .combined
    @State private var isExporting = false
    @State private var showingShareSheet = false
    @State private var showingMailComposer = false
    @State private var exportURLs: [URL] = []
    @State private var showingExportSuccess = false
    @State private var showingMailError = false
    
    enum ExportType: String, CaseIterable {
        case combined = "Combined File"
        case individual = "Individual Files"
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Data Summary Section
                Section {
                    DataSummaryRow(icon: "building.2", title: "Businesses", count: businesses.count)
                    DataSummaryRow(icon: "chart.line.uptrend.xyaxis", title: "Valuations", count: valuations.count)
                    DataSummaryRow(icon: "envelope", title: "Correspondence", count: correspondence.count)
                    DataSummaryRow(icon: "person.fill", title: "Owners", count: owners.count)
                    DataSummaryRow(icon: "person.badge.shield.checkmark", title: "Brokers", count: brokers.count)
                } header: {
                    Text("Data to Export")
                } footer: {
                    Text("All data will be exported in CSV format, which can be opened in Excel, Numbers, or Google Sheets.")
                }
                
                // Export Type Section
                Section {
                    Picker("Export Format", selection: $exportType) {
                        ForEach(ExportType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Export Format")
                } footer: {
                    Text(exportType == .combined 
                         ? "Creates a single CSV file with all data organized in sections."
                         : "Creates separate CSV files for each data type.")
                }
                
                // Export Actions Section
                Section {
                    // Share button
                    Button(action: performExport) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(AppTheme.Colors.primary)
                            Text("Export & Share")
                            Spacer()
                            if isExporting {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isExporting || totalDataCount == 0)
                    
                    // Email button
                    Button(action: exportAndEmail) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(AppTheme.Colors.primary)
                            Text("Export & Email")
                            Spacer()
                            if isExporting {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isExporting || totalDataCount == 0 || !MFMailComposeViewController.canSendMail())
                } header: {
                    Text("Export Options")
                } footer: {
                    if !MFMailComposeViewController.canSendMail() {
                        Text("Email is not configured on this device. Use Share to send via other methods.")
                            .foregroundColor(AppTheme.Colors.warning)
                    }
                }
                
                // Info Section
                Section {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        InfoRow(icon: "lock.shield", text: "Your data stays on your device until you choose to share it")
                        InfoRow(icon: "doc.text", text: "CSV files can be imported into spreadsheet apps")
                        InfoRow(icon: "arrow.clockwise", text: "Export regularly to backup your data")
                    }
                } header: {
                    Text("About Export")
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: exportURLs)
            }
            .sheet(isPresented: $showingMailComposer) {
                MailComposerView(urls: exportURLs) { result in
                    showingMailComposer = false
                    if case .sent = result {
                        showingExportSuccess = true
                    }
                }
            }
            .alert("Export Successful", isPresented: $showingExportSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your data has been exported successfully.")
            }
            .alert("Email Not Available", isPresented: $showingMailError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Email is not configured on this device. Please use the Share option instead.")
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalDataCount: Int {
        businesses.count + valuations.count + correspondence.count + owners.count + brokers.count
    }
    
    // MARK: - Export Functions
    
    private func performExport() {
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let urls = generateExportFiles()
            
            DispatchQueue.main.async {
                self.exportURLs = urls
                self.isExporting = false
                if !urls.isEmpty {
                    self.showingShareSheet = true
                }
            }
        }
    }
    
    private func exportAndEmail() {
        guard MFMailComposeViewController.canSendMail() else {
            showingMailError = true
            return
        }
        
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let urls = generateExportFiles()
            
            DispatchQueue.main.async {
                self.exportURLs = urls
                self.isExporting = false
                if !urls.isEmpty {
                    self.showingMailComposer = true
                }
            }
        }
    }
    
    private func generateExportFiles() -> [URL] {
        switch exportType {
        case .combined:
            return DataExportService.createExportFiles(
                businesses: businesses,
                valuations: valuations,
                correspondence: correspondence,
                owners: owners,
                brokers: brokers
            )
        case .individual:
            return DataExportService.createIndividualExportFiles(
                businesses: businesses,
                valuations: valuations,
                correspondence: correspondence,
                owners: owners,
                brokers: brokers
            )
        }
    }
}

// MARK: - Supporting Views

struct DataSummaryRow: View {
    let icon: String
    let title: String
    let count: Int
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 24)
            
            Text(title)
            
            Spacer()
            
            Text("\(count)")
                .foregroundColor(count > 0 ? AppTheme.Colors.primary : AppTheme.Colors.secondary)
                .fontWeight(count > 0 ? .semibold : .regular)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.Colors.secondary)
                .frame(width: 20)
            
            Text(text)
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.secondary)
        }
    }
}

// ShareSheet is defined in ValuationExportView.swift

// MARK: - Mail Composer

struct MailComposerView: UIViewControllerRepresentable {
    let urls: [URL]
    let completion: (MFMailComposeResult) -> Void
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setSubject("Business Eval - Data Export")
        composer.setMessageBody(
            "Please find attached the exported data from Business Eval.\n\nExport Date: \(Date().formatted(date: .long, time: .shortened))",
            isHTML: false
        )
        
        // Attach files
        for url in urls {
            if let data = try? Data(contentsOf: url) {
                let filename = url.lastPathComponent
                composer.addAttachmentData(data, mimeType: "text/csv", fileName: filename)
            }
        }
        
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let completion: (MFMailComposeResult) -> Void
        
        init(completion: @escaping (MFMailComposeResult) -> Void) {
            self.completion = completion
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true) {
                self.completion(result)
            }
        }
    }
}

#Preview {
    ExportDataView()
        .modelContainer(for: [Business.self, Valuation.self, Correspondence.self, Owner.self, Broker.self], inMemory: true)
}
