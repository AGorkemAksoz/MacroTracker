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
    
    @Published var nutrition: [Food] = []
    
    init(nutritionService: NutritionServiceInterface) {
        self.nutritionService = nutritionService
    }
    
    func fetchNutrition() {
        nutritionService.getNutrition()
            .receive(on: RunLoop.main)
            .sink { data in
            } receiveValue: { [weak self] data in
                guard let foods = data.foods else { return }
                print(foods)
                self?.nutrition = foods
            }
            .store(in: &cancellables)
    }
}
