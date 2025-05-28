//
//  NutritionDatabaseService.swift
//  MacroTracker
//
//  Created by Gorkem on 22.05.2025.
//

import Foundation
import SwiftData

// MARK: - Database Service Protocol
protocol DatabaseServiceInterface {
    func convertingToDatabaseModel(from item: Item, recorderDate: Date?) -> FoodItem
    func savingNutritionToLocalDatabase(_ nutrition: [Item], date recordedDate: Date?)
    func fetchSavedFoods() -> [FoodItem]
    func deleteFood(_ foodItem: FoodItem)
    func saveContext()
}

class NutritionDatabaseService: DatabaseServiceInterface {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func convertingToDatabaseModel(from item: Item, recorderDate: Date?) -> FoodItem {
        return FoodItem(
            name: item.name ?? "Unknown",
            calories: item.calories ?? 0,
            servingSizeG: item.servingSizeG ?? 0,
            fatTotalG: item.fatTotalG ?? 0,
            fatSaturatedG: item.fatSaturatedG ?? 0,
            proteinG: item.proteinG ?? 0,
            sodiumMg: item.sodiumMg ?? 0,
            potassiumMg: item.potassiumMg ?? 0,
            cholesterolMg: item.cholesterolMg ?? 0,
            carbohydratesTotalG: item.carbohydratesTotalG ?? 0,
            fiberG: item.fiberG ?? 0,
            sugarG: item.sugarG ?? 0,
            recordedDate: recorderDate ?? Date.now
        )
    }
    
    func savingNutritionToLocalDatabase(_ nutrition: [Item], date recordedDate: Date?) {
        /// It traverses an element of the array containing the data received from the service and converts the model into SwiftData and saves them to the local database.
        for item in nutrition {
            self.modelContext.insert(self.convertingToDatabaseModel(from: item, recorderDate: recordedDate))
            print("Food Item Date:", self.convertingToDatabaseModel(from: item, recorderDate: recordedDate).recordedDate)
        }
        saveContext()
    }
    
    func fetchSavedFoods() -> [FoodItem] {
        do {
            let descriptor = FetchDescriptor<FoodItem>()
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch saved foods: \(error)")
            return []
        }
    }
    
    func deleteFood(_ foodItem: FoodItem) {
        modelContext.delete(foodItem)
        saveContext()
    }
    
    func saveContext() {
        // Saving changes
        do {
            try self.modelContext.save()
        } catch {
            print("Failed to save to database: \(error)")
        }

    }
}
