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
                HStack {
                    Text("Foods")
                        .font(.dayDetailTitle)
                        .padding()
                        .navigationTitle(data.mealType.mealName)
                    Spacer()
                }
                
                ForEach(data.meals, id: \.id) { meal in
                    Button {
                        navigationCoordinator.navigate(to: .foodDetail(food: meal))
                    } label: {
                        MealTypeDetailViewCell(meal: meal)
                    }
                }
                
                HStack {
                    Text("Nutrition")
                        .font(.dayDetailTitle)
                        .padding()
                        .navigationTitle(data.mealType.mealName)
                    Spacer()
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    NutrientGridItem(title: "Fiber", value: data.meals.totalFiber, unit: "g")
                    NutrientGridItem(title: "Sugar", value: data.meals.totalSugar, unit: "g")
                    NutrientGridItem(title: "Cholesterol", value: Double(data.meals.totalCholesterol), unit: "mg")
                    NutrientGridItem(title: "Sodium", value: Double(data.meals.totalSodium), unit: "mg")
                    NutrientGridItem(title: "Potassium", value: Double(data.meals.totalPotassium), unit: "mg")
                    NutrientGridItem(title: "Protein", value: data.meals.totalProtein, unit: "g")
                    NutrientGridItem(title: "Carbs", value: data.meals.totalCarbs, unit: "g")
                    NutrientGridItem(title: "Fat", value: data.meals.totalFat, unit: "g")
                }
                .padding()
            }
            Spacer()
        }
    }
}

struct MealTypeDetailViewCell: View {
    var meal: FoodItem
    var body: some View {
        HStack {
            Image("breakfastIcon")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.appForegroundColor)
                .padding(12)
                .background(Color.containerBackgroundColor)
                .cornerRadius(8)
                .padding(.leading)
            
            VStack(alignment: .leading) {
                Text(meal.name)
                    .font(.primaryTitle)
                    .foregroundStyle(Color.appForegroundColor)
                    
                Text("\(meal.servingSizeG.formatted(.number)) gr.")
                    .font(.secondaryNumberTitle)
                    .foregroundStyle(Color.mealsDetailScreenSecondaryTitleColor)
            }
            Spacer()
        }
    }
}
