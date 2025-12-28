//
//  Business_EvalApp.swift
//  Business Eval
//
//  Created by Scott Campbell on 12/28/25.
//

import SwiftUI
import SwiftData

@main
struct Business_EvalApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Business.self,
            Owner.self,
            Correspondence.self,
            Valuation.self,
            BusinessImage.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
