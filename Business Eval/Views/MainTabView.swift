//
//  MainTabView.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            BusinessListView()
                .tabItem {
                    Label("Businesses", systemImage: "building.2")
                }
            
            CorrespondenceView()
                .tabItem {
                    Label("Correspondence", systemImage: "envelope")
                }
            
            BrokersView()
                .tabItem {
                    Label("Brokers", systemImage: "briefcase")
                }
            
            OwnersView()
                .tabItem {
                    Label("Owners", systemImage: "person.2")
                }
            
            ValuationsView()
                .tabItem {
                    Label("Valuations", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    MainTabView()
}
