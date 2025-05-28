//
//  FoodNutritionView.swift
//  MacroTracker
//
//  Created by Gorkem on 14.05.2025.
//

import SwiftUI

struct FoodNutritionView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @Binding var foods: [FoodItem]
    var body: some View {
        List(foods, id: \.name) { food in
            Section(header: Text(food.recordedDate.formatted(date: .abbreviated, time: .shortened))) {
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
                .swipeActions(edge: .trailing) {
                    Button(action: {
                        homeViewModel.deleteFood(food)
                        homeViewModel.savedNutrititon = homeViewModel.fetchSavedFoods()
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
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
