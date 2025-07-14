//
//  ProgressDataService.swift
//  MacroTracker
//
//  Created by Gorkem on 14.07.2025.
//

import Combine
import Foundation

/// Protocol for accessing progress-related data
protocol ProgressDataService {
    /// Current saved nutrition data
    var savedNutrition: [FoodItem] { get }

    /// Publisher for saved nutrition data changes
    var savedNutritionPublisher: AnyPublisher<[FoodItem], Never> { get }
}

/// Concrete implementation of ProgressDataService using HomeViewModel
class ConcreteProgressDataService: ProgressDataService {
    private let homeViewModel: HomeViewModel

    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
    }

    var savedNutrition: [FoodItem] {
        homeViewModel.savedNutrititon
    }

    var savedNutritionPublisher: AnyPublisher<[FoodItem], Never> {
        homeViewModel.$savedNutrititon.eraseToAnyPublisher()
    }
}
