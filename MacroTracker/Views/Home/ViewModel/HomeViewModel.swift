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
    
    /// Fetches nutrition information from the API with validation
    /// - Parameters:
    ///   - query: The food item to search for
    ///   - completion: Closure called when the fetch completes, with success status and optional error
    func fetchNutrition(query: String, completion: @escaping (Result<[Item], Error>) -> Void) {
        loadingState = .loading
        nutrition = [] // Reset nutrition array
        
        // Validate search query first
        let validationErrors = query.validateSearchQuery()
        if !validationErrors.isEmpty {
            loadingState = .error(validationErrors.first!.localizedDescription)
            completion(.failure(validationErrors.first!))
            return
        }
        
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
            DispatchQueue.main.async { [weak self] in
                self?.savedNutrititon = self?.fetchSavedFoods() ?? []
                completion(success)
            }
        case false:
            DispatchQueue.main.async {
                completion(false)
            }
        }
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
        // Ensure we're on the main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Check if the food item is already deleted
            guard !foodItem.isDeleted else { return }
            
            // Remove from the published array first to avoid retain cycles
            self.savedNutrititon.removeAll { $0.id == foodItem.id }
            
            // Delete from repository
            self.nutritionRepository.deleteFoodItem(foodItem)
            
            // Clear the entire array to release all SwiftData object references
            self.savedNutrititon.removeAll()
            
            // Refresh the saved nutrition data after deletion
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.savedNutrititon = self?.fetchSavedFoods() ?? []
            }
        }
    }
    
    /// Manually refresh saved nutrition data from the database
    func refreshSavedNutrition() {
        DispatchQueue.main.async { [weak self] in
            // Clear array first, then fetch fresh data
            self?.savedNutrititon.removeAll()
            self?.savedNutrititon = self?.fetchSavedFoods() ?? []
        }
    }
    
    func getFoodsByDate(_ date: Date, for mealType: MealTypes) -> [FoodItem] {
        let mealsForDate = self.getMealsForDate(date)  // Use passed date instead of selectedDate
        return mealsForDate.filter { $0.mealType == mealType }
    }

    /// Delete all foods for a specific meal type and date using batch deletion
    func deleteAllFoodsForMealTypeAndDate(mealType: MealTypes, date: Date) async {
        await MainActor.run {
            // Use the repository to perform batch deletion
            nutritionRepository.deleteAllFoodsForMealTypeAndDate(mealType: mealType, date: date)
            
            // Refresh the saved nutrition data
            refreshSavedNutrition()
        }
    }
}
