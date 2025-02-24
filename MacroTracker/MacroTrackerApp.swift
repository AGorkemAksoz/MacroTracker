//
//  MacroTrackerApp.swift
//  MacroTracker
//
//  Created by Gorkem on 24.02.2025.
//

import SwiftUI

@main
struct MacroTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
