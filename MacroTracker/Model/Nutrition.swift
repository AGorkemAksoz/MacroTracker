//
//  Nutrition.swift
//  MacroTracker
//
//  Created by Gorkem on 17.03.2025.
//


// MARK: - Nutrition
struct Nutrition: Codable {
    let foods: [Food]?
}

// MARK: - Item
struct Food: Codable {
    let sugarG, fiberG, servingSizeG: Double?
    let sodiumMg: Int?
    let name: String?
    let potassiumMg: Int?
    let fatSaturatedG, fatTotalG, calories: Double?
    let cholesterolMg: Int?
    let proteinG, carbohydratesTotalG: Double?

    enum CodingKeys: String, CodingKey {
        case sugarG = "sugar_g"
        case fiberG = "fiber_g"
        case servingSizeG = "serving_size_g"
        case sodiumMg = "sodium_mg"
        case name
        case potassiumMg = "potassium_mg"
        case fatSaturatedG = "fat_saturated_g"
        case fatTotalG = "fat_total_g"
        case calories
        case cholesterolMg = "cholesterol_mg"
        case proteinG = "protein_g"
        case carbohydratesTotalG = "carbohydrates_total_g"
    }
}

