//
//  DataExportService.swift
//  Business Eval
//
//  Created by Scott Campbell on 1/3/26.
//
//  Service to export all app data to CSV files for backup or sharing.
//

import Foundation
import SwiftData

/// Service responsible for exporting app data to CSV format
class DataExportService {
    
    // MARK: - CSV Generation
    
    /// Generates CSV content for all businesses
    static func generateBusinessesCSV(businesses: [Business]) -> String {
        var csv = "ID,Name,Industry,Location,Asking Price,Annual Revenue,Annual Profit,Employees,Years Established,Status,Description,Listing URL,Notes,Owner,Broker,Created,Updated\n"
        
        for business in businesses {
            let row = [
                business.id.uuidString,
                escapeCSV(business.name),
                escapeCSV(business.industry),
                escapeCSV(business.location),
                String(format: "%.2f", business.askingPrice),
                String(format: "%.2f", business.annualRevenue),
                String(format: "%.2f", business.annualProfit),
                String(business.numberOfEmployees),
                String(business.yearsEstablished),
                business.status.rawValue,
                escapeCSV(business.businessDescription),
                escapeCSV(business.listingURL ?? ""),
                escapeCSV(business.notes ?? ""),
                escapeCSV(business.owner?.name ?? ""),
                escapeCSV(business.broker?.name ?? ""),
                formatDate(business.createdAt),
                formatDate(business.updatedAt)
            ]
            csv += row.joined(separator: ",") + "\n"
        }
        
        return csv
    }
    
    /// Generates CSV content for all valuations
    static func generateValuationsCSV(valuations: [Valuation]) -> String {
        var csv = "ID,Business Name,Calculated Value,Multiple,Methodology,Confidence Level,Revenue Multiple,Profit Multiple,EBITDA Multiple,SDE Multiple,Notes,Created\n"
        
        for valuation in valuations {
            let row = [
                valuation.id.uuidString,
                escapeCSV(valuation.business?.name ?? "Unlinked"),
                String(format: "%.2f", valuation.calculatedValue),
                String(format: "%.2f", valuation.multiple),
                valuation.methodology.rawValue,
                valuation.confidenceLevel.rawValue,
                valuation.revenueMultiple.map { String(format: "%.2f", $0) } ?? "",
                valuation.profitMultiple.map { String(format: "%.2f", $0) } ?? "",
                valuation.ebitdaMultiple.map { String(format: "%.2f", $0) } ?? "",
                valuation.sdeMultiple.map { String(format: "%.2f", $0) } ?? "",
                escapeCSV(valuation.notes ?? ""),
                formatDate(valuation.createdAt)
            ]
            csv += row.joined(separator: ",") + "\n"
        }
        
        return csv
    }
    
    /// Generates CSV content for all correspondence
    static func generateCorrespondenceCSV(correspondence: [Correspondence]) -> String {
        var csv = "ID,Business Name,Subject,Content,Date,Type,Direction,Created\n"
        
        for item in correspondence {
            let row = [
                item.id.uuidString,
                escapeCSV(item.business?.name ?? "Unlinked"),
                escapeCSV(item.subject),
                escapeCSV(item.content),
                formatDate(item.date),
                item.type.rawValue,
                item.direction.rawValue,
                formatDate(item.createdAt)
            ]
            csv += row.joined(separator: ",") + "\n"
        }
        
        return csv
    }
    
    /// Generates CSV content for all owners
    static func generateOwnersCSV(owners: [Owner]) -> String {
        var csv = "ID,Name,Email,Phone,Title,Contact Preference,Notes,Business Count,Created,Updated\n"
        
        for owner in owners {
            let row = [
                owner.id.uuidString,
                escapeCSV(owner.name),
                escapeCSV(owner.email ?? ""),
                escapeCSV(owner.phone ?? ""),
                escapeCSV(owner.title ?? ""),
                owner.contactPreference.rawValue,
                escapeCSV(owner.notes ?? ""),
                String(owner.businesses.count),
                formatDate(owner.createdAt),
                formatDate(owner.updatedAt)
            ]
            csv += row.joined(separator: ",") + "\n"
        }
        
        return csv
    }
    
    /// Generates CSV content for all brokers
    static func generateBrokersCSV(brokers: [Broker]) -> String {
        var csv = "ID,Name,Email,Phone,Company,License,Commission %,Contact Preference,Notes,Business Count,Created,Updated\n"
        
        for broker in brokers {
            let row = [
                broker.id.uuidString,
                escapeCSV(broker.name),
                escapeCSV(broker.email ?? ""),
                escapeCSV(broker.phone ?? ""),
                escapeCSV(broker.company ?? ""),
                escapeCSV(broker.license ?? ""),
                broker.commission.map { String(format: "%.2f", $0) } ?? "",
                broker.contactPreference.rawValue,
                escapeCSV(broker.notes ?? ""),
                String(broker.businesses.count),
                formatDate(broker.createdAt),
                formatDate(broker.updatedAt)
            ]
            csv += row.joined(separator: ",") + "\n"
        }
        
        return csv
    }
    
    // MARK: - Combined Export
    
    /// Generates a combined CSV with all data in separate sections
    static func generateCombinedCSV(
        businesses: [Business],
        valuations: [Valuation],
        correspondence: [Correspondence],
        owners: [Owner],
        brokers: [Broker]
    ) -> String {
        var csv = "Business Eval - Data Export\n"
        csv += "Export Date: \(formatDate(Date()))\n"
        csv += "\n"
        
        // Summary
        csv += "=== SUMMARY ===\n"
        csv += "Businesses: \(businesses.count)\n"
        csv += "Valuations: \(valuations.count)\n"
        csv += "Correspondence: \(correspondence.count)\n"
        csv += "Owners: \(owners.count)\n"
        csv += "Brokers: \(brokers.count)\n"
        csv += "\n"
        
        // Businesses
        csv += "=== BUSINESSES ===\n"
        csv += generateBusinessesCSV(businesses: businesses)
        csv += "\n"
        
        // Valuations
        csv += "=== VALUATIONS ===\n"
        csv += generateValuationsCSV(valuations: valuations)
        csv += "\n"
        
        // Correspondence
        csv += "=== CORRESPONDENCE ===\n"
        csv += generateCorrespondenceCSV(correspondence: correspondence)
        csv += "\n"
        
        // Owners
        csv += "=== OWNERS ===\n"
        csv += generateOwnersCSV(owners: owners)
        csv += "\n"
        
        // Brokers
        csv += "=== BROKERS ===\n"
        csv += generateBrokersCSV(brokers: brokers)
        
        return csv
    }
    
    // MARK: - File Operations
    
    /// Saves CSV content to a temporary file and returns the URL
    static func saveToTemporaryFile(content: String, filename: String) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(filename)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error saving CSV file: \(error)")
            return nil
        }
    }
    
    /// Creates export files for all data types
    static func createExportFiles(
        businesses: [Business],
        valuations: [Valuation],
        correspondence: [Correspondence],
        owners: [Owner],
        brokers: [Broker]
    ) -> [URL] {
        var urls: [URL] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        // Combined export
        let combinedCSV = generateCombinedCSV(
            businesses: businesses,
            valuations: valuations,
            correspondence: correspondence,
            owners: owners,
            brokers: brokers
        )
        if let url = saveToTemporaryFile(content: combinedCSV, filename: "BusinessEval_Export_\(dateString).csv") {
            urls.append(url)
        }
        
        return urls
    }
    
    /// Creates individual export files for each data type
    static func createIndividualExportFiles(
        businesses: [Business],
        valuations: [Valuation],
        correspondence: [Correspondence],
        owners: [Owner],
        brokers: [Broker]
    ) -> [URL] {
        var urls: [URL] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        // Businesses
        if !businesses.isEmpty {
            let csv = generateBusinessesCSV(businesses: businesses)
            if let url = saveToTemporaryFile(content: csv, filename: "Businesses_\(dateString).csv") {
                urls.append(url)
            }
        }
        
        // Valuations
        if !valuations.isEmpty {
            let csv = generateValuationsCSV(valuations: valuations)
            if let url = saveToTemporaryFile(content: csv, filename: "Valuations_\(dateString).csv") {
                urls.append(url)
            }
        }
        
        // Correspondence
        if !correspondence.isEmpty {
            let csv = generateCorrespondenceCSV(correspondence: correspondence)
            if let url = saveToTemporaryFile(content: csv, filename: "Correspondence_\(dateString).csv") {
                urls.append(url)
            }
        }
        
        // Owners
        if !owners.isEmpty {
            let csv = generateOwnersCSV(owners: owners)
            if let url = saveToTemporaryFile(content: csv, filename: "Owners_\(dateString).csv") {
                urls.append(url)
            }
        }
        
        // Brokers
        if !brokers.isEmpty {
            let csv = generateBrokersCSV(brokers: brokers)
            if let url = saveToTemporaryFile(content: csv, filename: "Brokers_\(dateString).csv") {
                urls.append(url)
            }
        }
        
        return urls
    }
    
    // MARK: - Helper Functions
    
    /// Escapes special characters in CSV fields
    private static func escapeCSV(_ value: String) -> String {
        var escaped = value
        // Replace newlines with spaces
        escaped = escaped.replacingOccurrences(of: "\n", with: " ")
        escaped = escaped.replacingOccurrences(of: "\r", with: " ")
        
        // If contains comma, quote, or leading/trailing spaces, wrap in quotes
        if escaped.contains(",") || escaped.contains("\"") || escaped.hasPrefix(" ") || escaped.hasSuffix(" ") {
            // Escape existing quotes by doubling them
            escaped = escaped.replacingOccurrences(of: "\"", with: "\"\"")
            escaped = "\"\(escaped)\""
        }
        
        return escaped
    }
    
    /// Formats a date for CSV export
    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
}
