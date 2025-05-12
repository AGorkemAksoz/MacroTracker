//
//  NutritionService.swift
//  MacroTracker
//
//  Created by Gorkem on 17.03.2025.
//

import Combine
import Foundation

protocol NutritionServiceInterface {
    func getNutrition(for query: String) -> AnyPublisher<Nutrition, Error>
}

class NutritionService: NutritionServiceInterface {
    let apiClient = APIClient<NutritionEndpoint>()
    
    func getNutrition(for query: String) -> AnyPublisher<Nutrition, Error> {
        return apiClient.request(.getNutrition(query: query))
    }
}
