//
//  NutritionService.swift
//  MacroTracker
//
//  Created by Gorkem on 17.03.2025.
//

import Combine
import Foundation

protocol NutritionServiceInterface {
    func getNutrition() -> AnyPublisher<Nutrition, Error>
}

class NutritionService: NutritionServiceInterface {
    let apiClient = APIClient<NutritionEndpoint>()
    
    func getNutrition() -> AnyPublisher<Nutrition, Error> {
        let query = "Last lunch I had 1lb of brisket and 200 grams of rice"
        return apiClient.request(.getNutrition(query: query))
    }
}
