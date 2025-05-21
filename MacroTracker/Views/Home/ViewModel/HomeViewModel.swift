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
    
    
    @Published var nutrition: [Item] = []
    @Published var savedNutrititon: [FoodItem] = []
    
    init(nutritionService: NutritionServiceInterface, modelContext: ModelContext) {
        self.nutritionService = nutritionService
        self.modelContext = modelContext
    }
    
    func fetchNutrition(for query: String) async {
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
            }
            .store(in: &cancellables)
        print("FETCH")
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
    
    func savingNutritionToLocalDatabase(context: ModelContext) {
        
        for item in nutrition {
            context.insert(self.convertingToDatabaseModel(from: item))
        }
        
        // Değişiklikleri kaydet
        do {
            try self.modelContext.save()
        } catch {
            print("Failed to save to database: \(error)")
        }
        print("Saved")
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
        savedNutrititon.reduce(0) { $0 + ($1.proteinG ?? 0) }
    }

    var totalCarbs: Double {
        savedNutrititon.reduce(0) { $0 + ($1.carbohydratesTotalG ?? 0) }
    }

    var totalFat: Double {
        savedNutrititon.reduce(0) { $0 + ($1.fatTotalG ?? 0) }
    }
    
    var totalSugar: Double {
        savedNutrititon.reduce(0) { $0 + ($1.sugarG ?? 0) }
    }
}
