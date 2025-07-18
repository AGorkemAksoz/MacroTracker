//
//  FoodItem.swift
//  MacroTracker
//
//  Created by Gorkem on 15.05.2025.
//

import Foundation
import SwiftData

enum MealTypes: String, CaseIterable, Codable {
    case breakfast, lunch, dinner, snack
    
    var mealName: String {
        switch self {
        case .breakfast:
            return "Breakfast"
        case .lunch:
            return "Lunch"
        case .dinner:
            return "Dinner"
        case .snack:
            return "Snack"
        }
    }
    
    var iconName: String {
        switch self {
        case .breakfast:
            return "breakfastIcon"
        case .lunch:
            return "breakfastIcon"
        case .dinner:
            return "dinnerIcon"
        case .snack:
            return "snackIcon"
        }
    }
}

@Model
class FoodItem {
    let id: String
    var name: String
    var calories: Double
    var servingSizeG: Double
    var fatTotalG: Double
    var fatSaturatedG: Double
    var proteinG: Double
    var sodiumMg: Int
    var potassiumMg: Int
    var cholesterolMg: Int
    var carbohydratesTotalG: Double
    var fiberG: Double
    var sugarG: Double
    var recordedDate: Date
    var mealType: MealTypes

    init(id: String = UUID().uuidString,
         name: String = "Unknown",
         calories: Double = 0,
         servingSizeG: Double = 0,
         fatTotalG: Double = 0,
         fatSaturatedG: Double = 0,
         proteinG: Double = 0,
         sodiumMg: Int = 0,
         potassiumMg: Int = 0,
         cholesterolMg: Int = 0,
         carbohydratesTotalG: Double = 0,
         fiberG: Double = 0,
         sugarG: Double = 0,
         recordedDate: Date = Date.now,
         mealType: MealTypes = .breakfast) {
        
        self.id = id
        self.name = name
        self.calories = calories
        self.servingSizeG = servingSizeG
        self.fatTotalG = fatTotalG
        self.fatSaturatedG = fatSaturatedG
        self.proteinG = proteinG
        self.sodiumMg = sodiumMg
        self.potassiumMg = potassiumMg
        self.cholesterolMg = cholesterolMg
        self.carbohydratesTotalG = carbohydratesTotalG
        self.fiberG = fiberG
        self.sugarG = sugarG
        self.recordedDate = recordedDate
        self.mealType = mealType
    }
}
