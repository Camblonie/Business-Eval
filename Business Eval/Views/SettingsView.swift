//
//  SettingsView.swift
//  Business Eval
//
//  Created by Scott Campbell on 1/3/26.
//
//  Settings and tools view including data export functionality.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @State private var showingExportData = false
    
    var body: some View {
        NavigationView {
            List {
                // Data Management Section
                Section {
                    Button(action: { showingExportData = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(AppTheme.Colors.primary)
                                .frame(width: 28)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Export Data")
                                    .foregroundColor(.primary)
                                Text("Export all data to CSV file")
                                    .font(AppTheme.Fonts.caption)
                                    .foregroundColor(AppTheme.Colors.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                        }
                    }
                } header: {
                    Text("Data Management")
                }
                
                // App Info Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundColor(AppTheme.Colors.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                            .foregroundColor(AppTheme.Colors.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingExportData) {
                ExportDataView()
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [Business.self, Valuation.self, Correspondence.self, Owner.self, Broker.self], inMemory: true)
}
