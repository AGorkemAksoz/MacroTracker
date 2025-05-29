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
        List(foods, id: \.id) { food in
            NavigationLink(destination: FoodDetailView(foodItem: food)) {
                FoodRowView(food: food)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            homeViewModel.deleteFood(food)
                            homeViewModel.savedNutrititon = homeViewModel.fetchSavedFoods()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }
}

struct FoodRowView: View {
    let food: FoodItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(food.mealType.mealName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(food.recordedDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(food.name)
                .font(.body)
            
            HStack(spacing: 16) {
                MacroInfoView(label: "Cal", value: String(format: "%.0f", food.calories))
                MacroInfoView(label: "P", value: String(format: "%.1fg", food.proteinG))
                MacroInfoView(label: "C", value: String(format: "%.1fg", food.carbohydratesTotalG))
                MacroInfoView(label: "F", value: String(format: "%.1fg", food.fatTotalG))
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }
}

struct MacroInfoView: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}
