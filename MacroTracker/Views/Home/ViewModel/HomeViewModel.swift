//
//  HomeViewModel.swift
//  MacroTracker
//
//  Created by Gorkem on 17.03.2025.
//

import Combine
import Foundation
import SwiftData

/// A view model that manages the business logic and data for the home screen
///
/// HomeViewModel is responsible for:
/// - Managing nutrition data fetching and storage
/// - Calculating macro totals
/// - Coordinating between the view and services
final class HomeViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    var modelContext: ModelContext
    private let nutritionRepository: NutritionRepositoryInterface
    
    /// Represents the current state of data loading
    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
        
        static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case (.loading, .loading):
                return true
            case (.loaded, .loaded):
                return true
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
        }
    }
    
    // MARK: - Published Properties
    
    /// Current loading state of the view model
    @Published private(set) var loadingState: LoadingState = .idle
    
    /// Currently fetched nutrition items from the API
    @Published private(set) var nutrition: [Item] = []
    
    /// Saved nutrition items from the database
    @Published var savedNutrititon: [FoodItem] = []
    
    @Published var todaysMeals: [FoodItem] = []
    
    @Published var selectedDate: Date = Date()
    
    init(nutritionRepository: NutritionRepositoryInterface,
         modelContext: ModelContext) {
        self.modelContext = modelContext
        self.nutritionRepository = nutritionRepository
        self.savedNutrititon = self.fetchSavedFoods()
    }
    
    /// Fetches nutrition information from the API
    /// - Parameters:
    ///   - query: The food item to search for
    ///   - completion: Closure called when the fetch completes, with success status and optional error
    func fetchNutrition(query: String, completion: @escaping (Result<[Item], Error>) -> Void) {
        loadingState = .loading
        nutrition = [] // Reset nutrition array
        
        nutritionRepository.searchNutrition(query: query)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionStatus in
                guard let self = self else { return }
                
                switch completionStatus {
                case .finished:
                    self.loadingState = .loaded
                case .failure(let error):
                    self.loadingState = .error(error.localizedDescription)
                    self.nutrition = []
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            } receiveValue: { [weak self] items in
                guard let self = self else { return }
                self.nutrition = items
                DispatchQueue.main.async {
                    completion(.success(items))
                }
            }
            .store(in: &cancellables)
    }
    
    /// Convenience method to perform both fetch and save operations
    /// - Parameters:
    ///   - query: The food item to search for
    ///   - date: Date when the food was consumed
    ///   - mealType: Type of meal (breakfast, lunch, etc.)
    ///   - completion: Closure called when both operations complete, with success status
    func processFoodEntry(items: [Item], date: Date, mealType: MealTypes, completion: @escaping (Bool) -> Void) {
        let success = self.nutritionRepository.saveFoodItems(items, date: date, mealType: mealType)
        
        switch success {
        case true:
            self.savedNutrititon = self.fetchSavedFoods()
            completion(success)
        case false:
            completion(false)
        }
        
        //        fetchNutrition(query: query) { [weak self] result in
        //            guard let self = self else {
        //                completion(false)
        //                return
        //            }
        //
        //            switch result {
        //            case .success(let items):
        //                let success = self.nutritionRepository.saveFoodItems(items, date: date, mealType: mealType)
        //                self.savedNutrititon = self.fetchSavedFoods()
        //                completion(success)
        //            case .failure:
        //                completion(false)
        //            }
        //        }
    }
    
    /// Updates the model context
    func updateModelContext(_ newModelContext: ModelContext) {
        self.modelContext = newModelContext
    }
    
    // MARK: - Computed Properties
    
    var totalProtein: Double {
        savedNutrititon.reduce(0) { $0 + ($1.proteinG) }
    }
    
    var totalCarbs: Double {
        savedNutrititon.reduce(0) { $0 + ($1.carbohydratesTotalG) }
    }
    
    var totalFat: Double {
        savedNutrititon.reduce(0) { $0 + ($1.fatTotalG) }
    }
    
    var totalSugar: Double {
        savedNutrititon.reduce(0) { $0 + ($1.sugarG) }
    }
    
    var totalCaloriesForSelectedDate: Double {
        let meals = getMealsForDate(selectedDate)
        return meals.reduce(0) { $0 + $1.calories }
    }
    
    var totalProteinForSelectedDate: Double {
        let meals = getMealsForDate(selectedDate)
        return meals.reduce(0) { $0 + $1.proteinG }
    }
    
    var totalCarbsForSelectedDate: Double {
        let meals = getMealsForDate(selectedDate)
        return meals.reduce(0) { $0 + $1.carbohydratesTotalG }
    }
    
    var totalFatForSelectedDate: Double {
        let meals = getMealsForDate(selectedDate)
        return meals.reduce(0) { $0 + $1.fatTotalG }
    }
    
    // MARK: - Methods
    
    func getMealsForDate(_ date: Date) -> [FoodItem] {
        return nutritionRepository.getFoodItems(for: date)
    }
    
    func updateSelectedDate(_ date: Date) {
        selectedDate = date
        // This will trigger the computed properties to update
        objectWillChange.send()
    }
    
    func refreshTodaysMeals() {
        todaysMeals = getMealsForDate(Date())
    }
    
    func getAllLoggedDates() -> [Date] {
        let calendar = Calendar.current
        // Get all unique dates, sorted from newest to oldest
        let uniqueDates = Set(savedNutrititon.map { calendar.startOfDay(for: $0.recordedDate) })
        return Array(uniqueDates).sorted(by: >)
    }
    
    func getMealsByType(for date: Date) -> [MealTypes: [FoodItem]] {
        let mealsForDate = getMealsForDate(date)
        return Dictionary(grouping: mealsForDate, by: { $0.mealType })
    }
    
    // MARK: - Database Operations
    
    func fetchSavedFoods() -> [FoodItem] {
        return nutritionRepository.getAllFoodItems()
    }
    
    func deleteFood(_ foodItem: FoodItem) {
        nutritionRepository.deleteFoodItem(foodItem)
    }
}
