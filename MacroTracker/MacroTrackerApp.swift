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
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: FoodItem.self)
    }
}
