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
    func convertingToDatabaseModel(from item: Item, recorderDate: Date?, mealType: MealTypes?) -> FoodItem
    func savingNutritionToLocalDatabase(_ nutrition: [Item], date recordedDate: Date?, mealType: MealTypes?)
    func fetchSavedFoods() -> [FoodItem]
    func deleteFood(_ foodItem: FoodItem)
    func saveContext()
}

class NutritionDatabaseService: DatabaseServiceInterface {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func convertingToDatabaseModel(from item: Item, recorderDate: Date?, mealType: MealTypes?) -> FoodItem {
        return FoodItem(
            id: UUID().uuidString,  // Generate new UUID for each food item
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
            recordedDate: recorderDate ?? Date.now,
            mealType: mealType ?? .breakfeast
        )
    }
    
    func savingNutritionToLocalDatabase(_ nutrition: [Item], date recordedDate: Date?, mealType: MealTypes?) {
        /// It traverses an element of the array containing the data received from the service and converts the model into SwiftData and saves them to the local database.
        for item in nutrition {
            let foodItem = convertingToDatabaseModel(
                from: item,
                recorderDate: recordedDate,
                mealType: mealType
            )
            modelContext.insert(foodItem)
        }
        saveContext()
    }
    
    func fetchSavedFoods() -> [FoodItem] {
        do {
            let descriptor = FetchDescriptor<FoodItem>(
                sortBy: [SortDescriptor(\.recordedDate, order: .reverse)]
            )
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
