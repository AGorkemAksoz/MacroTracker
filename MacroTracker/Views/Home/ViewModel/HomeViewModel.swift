//
//  HomeViewModel.swift
//  MacroTracker
//
//  Created by Gorkem on 17.03.2025.
//

import Combine
import Foundation

class HomeViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    let nutritionService: NutritionServiceInterface
    
    @Published var nutrition: [Item] = []
    
    init(nutritionService: NutritionServiceInterface) {
        self.nutritionService = nutritionService
    }
    
    func fetchNutrition(for query: String) {
        nutritionService.getNutrition(for: query)
            .receive(on: RunLoop.main)
            .sink { data in
            } receiveValue: { [weak self] data in
                guard let foods = data.items else { return }
                self?.nutrition = foods
                print(foods)
            }
            .store(in: &cancellables)
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
