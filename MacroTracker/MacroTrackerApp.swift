//
//  MacroTrackerApp.swift
//  MacroTracker
//
//  Created by Gorkem on 24.02.2025.
//

import SwiftData
import SwiftUI

@main
struct MacroTrackerApp: App {
    // ModelContainer at app level
     let modelContainer: ModelContainer
    // Add dependency container
    let dependencyContainer: DependencyContainerProtocol
     
     init() {
         do {
            let container = try ModelContainer(for: FoodItem.self)
            self.modelContainer = container
            // Initialize dependency container with model context
            self.dependencyContainer = DependencyContainer(modelContext: container.mainContext)
         } catch {
             fatalError("Failed to create ModelContainer: \(error)")
         }
     }
    
    var body: some Scene {
        WindowGroup {
            HomeView(dependencyContainer: dependencyContainer)
        }
        .modelContainer(modelContainer)
    }
}
