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
    let nutritionService: NutritionServiceInterface
    let databaseService: DatabaseServiceInterface
    
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
    
    init(nutritionService: NutritionServiceInterface,
         modelContext: ModelContext,
         databaseService: DatabaseServiceInterface) {
        self.nutritionService = nutritionService
        self.modelContext = modelContext
        self.databaseService = databaseService
        self.savedNutrititon = self.fetchSavedFoods()
    }
    
    /// Fetches nutrition information from the API
    /// - Parameters:
    ///   - query: The food item to search for
    ///   - completion: Closure called when the fetch completes, with success status and optional error
    func fetchNutrition(query: String, completion: @escaping (Result<[Item], Error>) -> Void) {
        loadingState = .loading
        nutrition = [] // Reset nutrition array
        
        nutritionService.getNutrition(for: query)
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
            } receiveValue: { [weak self] data in
                guard let self = self, let foods = data.items else {
                    let error = NSError(domain: "NutritionError", 
                                      code: -1, 
                                      userInfo: [NSLocalizedDescriptionKey: "No nutrition data found"])
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                self.nutrition = foods
                DispatchQueue.main.async {
                    completion(.success(foods))
                }
            }
            .store(in: &cancellables)
    }
    
    /// Saves the fetched nutrition data to the local database
    /// - Parameters:
    ///   - items: The nutrition items to save
    ///   - date: Date when the food was consumed
    ///   - mealType: Type of meal (breakfast, lunch, etc.)
    ///   - completion: Closure called when save completes, with success status
    func saveNutrition(items: [Item], date: Date, mealType: MealTypes, completion: @escaping (Bool) -> Void) {
        databaseService.savingNutritionToLocalDatabase(items, date: date, mealType: mealType)
        savedNutrititon = fetchSavedFoods()
        completion(true)
    }
    
    /// Convenience method to perform both fetch and save operations
    /// - Parameters:
    ///   - query: The food item to search for
    ///   - date: Date when the food was consumed
    ///   - mealType: Type of meal (breakfast, lunch, etc.)
    ///   - completion: Closure called when both operations complete, with success status
    func processFoodEntry(query: String, date: Date, mealType: MealTypes, completion: @escaping (Bool) -> Void) {
        fetchNutrition(query: query) { [weak self] result in
            guard let self = self else { 
                completion(false)
                return 
            }
            
            switch result {
            case .success(let items):
                self.saveNutrition(items: items, date: date, mealType: mealType, completion: completion)
            case .failure:
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
    
    // MARK: - Database Operations
    
    func fetchSavedFoods() -> [FoodItem] {
        databaseService.fetchSavedFoods()
    }
    
    func deleteFood(_ foodItem: FoodItem) {
        databaseService.deleteFood(foodItem)
    }
}
