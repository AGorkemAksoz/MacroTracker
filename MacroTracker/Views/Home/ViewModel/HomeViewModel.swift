//
//  HomeViewModel.swift
//  MacroTracker
//
//  Created by Gorkem on 17.03.2025.
//

import Combine
import Foundation
import SwiftData

class HomeViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    let nutritionService: NutritionServiceInterface
    var modelContext: ModelContext
    
    @Published var isLoaded: Bool = false
    @Published var savedNutrititon: [FoodItem] = []
    
    init(nutritionService: NutritionServiceInterface, modelContext: ModelContext) {
        self.nutritionService = nutritionService
        self.modelContext = modelContext
        self.savedNutrititon = self.fetchSavedFoods()
    }
    
    func fetchNutrition(for query: String) {
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
                savingNutritionToLocalDatabase(foods)
                self.savedNutrititon = self.fetchSavedFoods()
                self.isLoaded = true
            }
            .store(in: &cancellables)
    }
    
    func convertingToDatabaseModel(from item: Item) -> FoodItem {
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
            sugarG: item.sugarG ?? 0
        )
    }
    
    func savingNutritionToLocalDatabase(_ nutritions: [Item]) {
        /// It traverses an element of the array containing the data received from the service and converts the model into SwiftData and saves them to the local database.
        for item in nutritions {
            self.modelContext.insert(self.convertingToDatabaseModel(from: item))
        }
        
        // Saving changes
        do {
            try self.modelContext.save()
        } catch {
            print("Failed to save to database: \(error)")
        }
    }
    
    // ModelContext'i güncellemek için eklenen metod
    func updateModelContext(_ newModelContext: ModelContext) {
        self.modelContext = newModelContext
    }
    
    // Veritabanından kayıtlı yemekleri getir
    func fetchSavedFoods() -> [FoodItem] {
        do {
            let descriptor = FetchDescriptor<FoodItem>()
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch saved foods: \(error)")
            return []
        }
    }
    
    // Belirli bir yemeği veritabanından silme
    func deleteFood(_ foodItem: FoodItem) {
        modelContext.delete(foodItem)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete food: \(error)")
        }
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
}
