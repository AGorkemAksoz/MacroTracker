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
            HomeView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
