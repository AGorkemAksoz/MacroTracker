//
//  FoodNutritionView.swift
//  MacroTracker
//
//  Created by Gorkem on 14.05.2025.
//

import SwiftUI

struct FoodNutritionView: View {
    @Binding var foods: [FoodItem]
    var body: some View {
        List(foods, id: \.name) { food in
            VStack(alignment: .leading, spacing: 8) {
                Text(food.name)
                    .font(.title2)
                
                FoodNutritionCellView(nutrition: "Serving Size(gr)", value: String(food.servingSizeG))
                FoodNutritionCellView(nutrition: "Protein(gr)", value: String(food.proteinG))
                FoodNutritionCellView(nutrition: "Calories", value: String(food.calories))
                FoodNutritionCellView(nutrition: "Carbonhydrate", value: String(food.carbohydratesTotalG))
                FoodNutritionCellView(nutrition: "Fat Total", value: String(food.fatTotalG))
                FoodNutritionCellView(nutrition: "Sugar(gr)", value: String(food.sugarG))
            }
        }
    }
}

struct FoodNutritionCellView: View {
    let nutrition: String
    let value: String
    var body: some View {
        HStack(spacing: 8) {
            Text(nutrition)
            Text(value)
        }
    }
}
