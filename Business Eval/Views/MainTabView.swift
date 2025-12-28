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
            
            ValuationsView()
                .tabItem {
                    Label("Valuations", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            CorrespondenceView()
                .tabItem {
                    Label("Correspondence", systemImage: "envelope")
                }
            
            OwnersView()
                .tabItem {
                    Label("Owners", systemImage: "person.2")
                }
        }
    }
}

#Preview {
    MainTabView()
}
