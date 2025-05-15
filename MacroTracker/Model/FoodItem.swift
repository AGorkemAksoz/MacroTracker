//
//  FoodItem.swift
//  MacroTracker
//
//  Created by Gorkem on 15.05.2025.
//

import Foundation
import SwiftData

@Model
class FoodItem {
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

    init(name: String = "Unknown",
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
         sugarG: Double = 0) {
        
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
    }
}
