//
//  MealTypeDetailView.swift
//  MacroTracker
//
//  Created by Gorkem on 13.06.2025.
//

import SwiftUI

struct MealTypeDetailView: View {
    let data: MealTypeDataProvider
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    
    init(data: MealTypeDataProvider) {
        self.data = data
    }
    
    // Convenience initializer for direct data
    init(mealsType: MealTypes, meals: [FoodItem]) {
        self.init(data: MealTypeData(mealType: mealsType, meals: meals))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Foods")
                
                ForEach(data.meals, id: \.id) { meal in
                    Button {
                        navigationCoordinator.navigate(to: .foodDetail(food: meal))
                    } label: {
                        IconCell(
                            iconName: data.mealType.iconName,
                            title: meal.name,
                            subtitle: "\(meal.servingSizeG.formatted(.number)) gr."
                        )
                    }
                }
                
                SectionHeader(title: "Nutrition")
                
                NutritionGrid(items: [
                    NutritionGridItem(title: "Fiber", value: data.meals.totalFiber, unit: "g"),
                    NutritionGridItem(title: "Sugar", value: data.meals.totalSugar, unit: "g"),
                    NutritionGridItem(title: "Cholesterol", value: Double(data.meals.totalCholesterol), unit: "mg"),
                    NutritionGridItem(title: "Sodium", value: Double(data.meals.totalSodium), unit: "mg"),
                    NutritionGridItem(title: "Potassium", value: Double(data.meals.totalPotassium), unit: "mg"),
                    NutritionGridItem(title: "Protein", value: data.meals.totalProtein, unit: "g"),
                    NutritionGridItem(title: "Carbs", value: data.meals.totalCarbs, unit: "g"),
                    NutritionGridItem(title: "Fat", value: data.meals.totalFat, unit: "g")
                ])
            }
            Spacer()
        }
        .navigationTitle(data.mealType.mealName)
    }
}
