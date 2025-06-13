//
//  DailyMealDetailView.swift
//  MacroTracker
//
//  Created by Ali Görkem Aksöz on 9.06.2025.
//

import SwiftUI

struct DailyMealDetailView: View {
    let data: DailyMealDataProvider
    let date: Date
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    
    init(data: DailyMealDataProvider, date: Date) {
        self.data = data
        self.date = date
    }
    
    // Convenience initializer for HomeViewModel
    init(date: Date, homeViewModel: HomeViewModel) {
        self.init(data: homeViewModel, date: date)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Meals")
                            .font(.dayDetailTitle)
                            .padding()
                        
                        ForEach(MealTypes.allCases, id: \.self) { mealType in
                            if let mealsForType = data.getMealsByType(for: date)[mealType] {
                                Button {
                                    navigationCoordinator.navigate(to: .mealTypeDetail(type: mealType, meals: mealsForType))
                                } label: {
                                    MealTypeSection(
                                        mealType: mealType,
                                        meals: mealsForType
                                    )
                                }
                            }
                        }
                    }
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Daily Summary")
                        .font(.dayDetailTitle)
                        .padding(.horizontal)
                    
                    let mealsByType = data.getMealsByType(for: date)
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        NutrientGridItem(title: "Fiber", value: mealsByType.totalFiber, unit: "g")
                        NutrientGridItem(title: "Sugar", value: mealsByType.totalSugar, unit: "g")
                        NutrientGridItem(title: "Cholesterol", value: Double(mealsByType.totalCholesterol), unit: "mg")
                        NutrientGridItem(title: "Sodium", value: Double(mealsByType.totalSodium), unit: "mg")
                        NutrientGridItem(title: "Potassium", value: Double(mealsByType.totalPotassium), unit: "mg")
                        NutrientGridItem(title: "Protein", value: mealsByType.totalProtein, unit: "g")
                        NutrientGridItem(title: "Carbs", value: mealsByType.totalCarbs, unit: "g")
                        NutrientGridItem(title: "Fat", value: mealsByType.totalFat, unit: "g")
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle(formatDate(date))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

struct MealTypeSection: View {
    let mealType: MealTypes
    let meals: [FoodItem]
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(mealType == .breakfeast ? "breakfastIcon" :
                    mealType == .lunch ? "breakfastIcon" :
                    mealType == .dinner ? "dinnerIcon" : "snackIcon")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.appForegroundColor)
                .padding(12)
                .background(Color.containerBackgroundColor)
                .cornerRadius(8)
                .padding(.leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mealType.mealName)
                    .font(.primaryTitle)
                    .foregroundStyle(Color.appForegroundColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(meals) { meal in
                        Text("\(meal.name): P: \(Int(meal.proteinG))g, C: \(Int(meal.carbohydratesTotalG))g, F: \(Int(meal.fatTotalG))g")
                    }
                    Text("Total: P: \(Int(meals.totalProtein))g, C: \(Int(meals.totalCarbs))g, F: \(Int(meals.totalFat))g")
                        .fontWeight(.medium)
                }
                .font(.secondaryNumberTitle)
                .foregroundStyle(Color.secondayNumberForegroundColor)
            }
        }
    }
}

struct NutrientGridItem: View {
    let title: String
    let value: Double
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.secondaryNumberTitle)
                .foregroundStyle(Color.mealsDetailScreenSecondaryTitleColor)
            Text("\(value, specifier: "%.1f") \(unit)")
                .font(.secondaryNumberTitle)
                .foregroundStyle(Color.appForegroundColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.containerBackgroundColor)
        .cornerRadius(8)
    }
}

struct FoodItemDetailView: View {
    var food: FoodItem
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(food.name)
                            .font(.dayDetailTitle)
                        
                        Text("\(food.servingSizeG.formatted(.number)) gr")
                            .font(.secondaryNumberTitle)
                        
                        VStack {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Calories")
                                        .font(.secondaryNumberTitle)
                                    
                                    Text(food.calories.formatted(.number))
                                        .font(.dayDetailTitle)
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: UIScreen.main.bounds.height / 8)
                        .frame(maxWidth: .infinity)
                        .background(Color.containerBackgroundColor)
                        .cornerRadius(8)
                        
                        Text("Macros")
                            .font(.dayDetailTitle)
                            .padding(.top)
                        
                        HStack {
                            Text("Protein")
                                .foregroundStyle(Color.mealsDetailScreenSecondaryTitleColor)
                            Spacer()
                            Text("\(food.proteinG.formatted(.number)) gr")
                            
                        }
                        .font(.secondaryNumberTitle)
                        
                        HStack {
                            Text("Carbs")
                                .foregroundStyle(Color.mealsDetailScreenSecondaryTitleColor)
                            Spacer()
                            Text("\(food.carbohydratesTotalG.formatted(.number)) gr")
                            
                        }
                        .font(.secondaryNumberTitle)
                        
                        HStack {
                            Text("Fats")
                                .foregroundStyle(Color.mealsDetailScreenSecondaryTitleColor)
                            Spacer()
                            Text("\(food.fatTotalG.formatted(.number)) gr")
                            
                        }
                        .font(.secondaryNumberTitle)
                        
                        Text("Micronutrients")
                            .font(.dayDetailTitle)
                            .padding(.top)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            NutrientGridItem(title: "Fiber", value: food.fiberG, unit: "g")
                            NutrientGridItem(title: "Sugar", value: food.sugarG, unit: "g")
                            NutrientGridItem(title: "Cholesterol", value: Double(food.cholesterolMg), unit: "mg")
                            NutrientGridItem(title: "Sodium", value: Double(food.sodiumMg), unit: "mg")
                            NutrientGridItem(title: "Potassium", value: Double(food.potassiumMg), unit: "mg")
                            NutrientGridItem(title: "Protein", value: food.proteinG, unit: "g")
                            NutrientGridItem(title: "Carbs", value: food.carbohydratesTotalG, unit: "g")
                            NutrientGridItem(title: "Fat Saturated", value: food.fatSaturatedG, unit: "g")
                        }
                    }
                    Spacer()
                }
                .padding()
                Spacer()
            }
            .navigationTitle("Food Detail")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
