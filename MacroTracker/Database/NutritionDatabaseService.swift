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
    func deleteAllFoodsForMealTypeAndDate(mealType: MealTypes, date: Date)
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
            mealType: mealType ?? .breakfast
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
        // Ensure we're on the main thread for SwiftData operations
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Check if the object is still valid and not already deleted
            guard !foodItem.isDeleted else { 
                print("Food item already deleted: \(foodItem.name)")
                return 
            }
            
            // Check if the object is still in the context
            guard self.modelContext.hasChanges || !foodItem.isDeleted else {
                print("Food item not in context or already deleted: \(foodItem.name)")
                return
            }
            
            // Delete the object
            self.modelContext.delete(foodItem)
            
            // Save context with error handling
            do {
                try self.modelContext.save()
                print("Successfully deleted food item: \(foodItem.name)")
            } catch {
                print("Failed to save context after deletion: \(error)")
            }
        }
    }
    
    func deleteAllFoodsForMealTypeAndDate(mealType: MealTypes, date: Date) {
        // Use batch deletion to avoid retain cycle issues
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            do {
                // Create a predicate to find all foods for the specific meal type and date
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                
                let predicate = #Predicate<FoodItem> { food in
                    food.mealType == mealType &&
                    food.recordedDate >= startOfDay &&
                    food.recordedDate < endOfDay
                }
                
                let descriptor = FetchDescriptor<FoodItem>(predicate: predicate)
                let foodsToDelete = try self.modelContext.fetch(descriptor)
                
                print("Found \(foodsToDelete.count) foods to delete for \(mealType.mealName) on \(date)")
                
                // Delete all found foods
                for food in foodsToDelete {
                    if !food.isDeleted {
                        self.modelContext.delete(food)
                    }
                }
                
                // Save the context
                try self.modelContext.save()
                print("Successfully deleted \(foodsToDelete.count) foods for \(mealType.mealName)")
                
            } catch {
                print("Failed to delete foods for \(mealType.mealName): \(error)")
            }
        }
    }
    
    func saveContext() {
        // Ensure we're on the main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            do {
                try self.modelContext.save()
            } catch {
                print("Failed to save to database: \(error)")
            }
        }
    }
}
