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
        // First, check the cache
        if let cachedItems = cacheService.getCachedNutrition(for: query) {
            return Just(cachedItems)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // If not in cache, fetch from API
        return nutritionService.getNutrition(for: query)
            .map { nutrition -> [Item] in
                let items = nutrition.items ?? []
                // Cache the results for future use
                self.cacheService.cacheNutrition(items, for: query)
                return items
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
} 
