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
    // ModelContainer'ı uygulama seviyesinde oluştur
     let modelContainer: ModelContainer
     
     init() {
         do {
             // FoodItem modelinizi ve diğer ilgili modelleri buraya ekleyin
             modelContainer = try ModelContainer(for: FoodItem.self)
         } catch {
             fatalError("Failed to create ModelContainer: \(error)")
         }
     }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(modelContainer)
    }
}
