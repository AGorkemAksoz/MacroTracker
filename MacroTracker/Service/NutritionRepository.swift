//
//  NutritionRepository.swift
//  MacroTracker
//
//  Created by Gorkem on 29.05.2025.
//

import Foundation
import Combine
import SwiftData

protocol NutritionRepositoryInterface {
    // Remote operations
    func searchNutrition(query: String) -> AnyPublisher<[Item], Error>
    
    // Local operations
    func saveFoodItems(_ items: [Item], date: Date, mealType: MealTypes) -> Bool
    func getAllFoodItems() -> [FoodItem]
    func getFoodItems(for date: Date) -> [FoodItem]
    func deleteFoodItem(_ item: FoodItem)
    func deleteAllFoodsForMealTypeAndDate(mealType: MealTypes, date: Date)
}

class NutritionRepository: NutritionRepositoryInterface {
    private let nutritionService: NutritionServiceInterface
    private let databaseService: DatabaseServiceInterface
    private let cacheService: NutritionCacheServiceInterface
    
    init(nutritionService: NutritionServiceInterface,
         databaseService: DatabaseServiceInterface,
         cacheService: NutritionCacheServiceInterface) {
        self.nutritionService = nutritionService
        self.databaseService = databaseService
        self.cacheService = cacheService
    }
    
    // MARK: - Remote Operations
    
    func searchNutrition(query: String) -> AnyPublisher<[Item], Error> {
        // Validate search query
        let validationErrors = query.validateSearchQuery()
        if !validationErrors.isEmpty {
            return Fail(error: validationErrors.first!)
                .eraseToAnyPublisher()
        }
        
        let sanitizedQuery = query.sanitizedSearchQuery()
        
        // First, check the cache
        if let cachedItems = cacheService.getCachedNutrition(for: sanitizedQuery) {
            return Just(cachedItems)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // If not in cache, fetch from API
        return nutritionService.getNutrition(for: sanitizedQuery)
            .map { nutrition -> [Item] in
                let items = nutrition.items ?? []
                
                // Validate and sanitize each item
                let validatedItems = items.compactMap { item -> Item? in
                    let validationErrors = item.validate()
                    
                    if !validationErrors.isEmpty {
                        print("Validation errors for item '\(item.name ?? "Unknown")': \(validationErrors)")
                        // Return sanitized version instead of failing completely
                        return item.sanitized()
                    }
                    
                    return item
                }
                
                // Cache the validated results
                self.cacheService.cacheNutrition(validatedItems, for: sanitizedQuery)
                return validatedItems
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Local Operations
    
    func saveFoodItems(_ items: [Item], date: Date, mealType: MealTypes) -> Bool {
        databaseService.savingNutritionToLocalDatabase(items, date: date, mealType: mealType)
        return true
    }
    
    func getAllFoodItems() -> [FoodItem] {
        return databaseService.fetchSavedFoods()
    }
    
    func getFoodItems(for date: Date) -> [FoodItem] {
        // Get all items and filter by date
        let allItems = databaseService.fetchSavedFoods()
        return allItems.filter { Calendar.current.isDate($0.recordedDate, inSameDayAs: date) }
    }
    
    func deleteFoodItem(_ item: FoodItem) {
        databaseService.deleteFood(item)
    }
    
    func deleteAllFoodsForMealTypeAndDate(mealType: MealTypes, date: Date) {
        databaseService.deleteAllFoodsForMealTypeAndDate(mealType: mealType, date: date)
    }
} 
