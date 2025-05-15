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
    let modelContext: ModelContext
    
    
    @Published var nutrition: [Item] = [] {
        didSet {
            for item in nutrition {
                saveToDatabase(from: item, context: modelContext)
            }
        }
    }
    
    init(nutritionService: NutritionServiceInterface, modelContext: ModelContext) {
        self.nutritionService = nutritionService
        self.modelContext = modelContext
    }
    
    func fetchNutrition(for query: String) {
        nutritionService.getNutrition(for: query)
            .receive(on: RunLoop.main)
            .sink { data in
            } receiveValue: { [weak self] data in
                guard let foods = data.items else { return }
                self?.nutrition += foods
            }
            .store(in: &cancellables)
    }
    
    func saveToDatabase(from item: Item, context: ModelContext) {
        let foodItem = FoodItem(
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
        
        context.insert(foodItem)
    }

    
    var totalProtein: Double {
        nutrition.reduce(0) { $0 + ($1.proteinG ?? 0) }
    }

    var totalCarbs: Double {
        nutrition.reduce(0) { $0 + ($1.carbohydratesTotalG ?? 0) }
    }

    var totalFat: Double {
        nutrition.reduce(0) { $0 + ($1.fatTotalG ?? 0) }
    }
    
    var totalSugar: Double {
        nutrition.reduce(0) { $0 + ($1.sugarG ?? 0) }
    }
}
