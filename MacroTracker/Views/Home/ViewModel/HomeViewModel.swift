//
//  HomeViewModel.swift
//  MacroTracker
//
//  Created by Gorkem on 17.03.2025.
//

import Combine
import Foundation
import SwiftData

final class HomeViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    var modelContext: ModelContext
    
    let nutritionService: NutritionServiceInterface
    let databaseService: DatabaseServiceInterface
    
    @Published var isLoaded: Bool = false
    @Published var nutrition: [Item] = []
    @Published var savedNutrititon: [FoodItem] = []
    
    init(nutritionService: NutritionServiceInterface, modelContext: ModelContext, databaseService: DatabaseServiceInterface) {
        self.nutritionService = nutritionService
        self.modelContext = modelContext
        self.databaseService = databaseService
        self.savedNutrititon = self.fetchSavedFoods()
    }
    
    func fetchNutrition(for query: String, completion: @escaping () -> ()) {
        self.isLoaded = false
        nutritionService.getNutrition(for: query)
            .receive(on: RunLoop.main)
            .sink { completion in
                // Hata durumunu ele almak için
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching nutrition: \(error)")
                }
            } receiveValue: { [weak self] data in
                guard let self = self, let foods = data.items else { return }
                self.nutrition += foods
                self.isLoaded = true
                completion()
            }
            .store(in: &cancellables)
    }
    
    // ModelContext'i güncellemek için eklenen metodx
    func updateModelContext(_ newModelContext: ModelContext) {
        self.modelContext = newModelContext
    }
    
    var totalProtein: Double {
        savedNutrititon.reduce(0) { $0 + ($1.proteinG)  }
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
    
    // MARK: - Database Functions
    func savingNutritionToLocalDatabase(date recordedDate: Date?) {
        databaseService.savingNutritionToLocalDatabase(nutrition, date: recordedDate)
    }
    
    // Veritabanından kayıtlı yemekleri getir
    func fetchSavedFoods() -> [FoodItem] {
        databaseService.fetchSavedFoods()
    }
    
    // Belirli bir yemeği veritabanından silme
    func deleteFood(_ foodItem: FoodItem) {
        databaseService.deleteFood(foodItem)
    }
}
