//
//  DailyMealDetailView.swift
//  MacroTracker
//
//  Created by Ali Görkem Aksöz on 9.06.2025.
//

import SwiftUI

struct DailyMealDetailView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    let date: Date
    
    var mealsByType: [MealTypes: [FoodItem]] {
        homeViewModel.getMealsByType(for: date)
    }
    
    var totalProtein: Double {
        mealsByType.values.flatMap { $0 }.reduce(0) { $0 + $1.proteinG }
    }
    
    var totalCarbs: Double {
        mealsByType.values.flatMap { $0 }.reduce(0) { $0 + $1.carbohydratesTotalG }
    }
    
    var totalFat: Double {
        mealsByType.values.flatMap { $0 }.reduce(0) { $0 + $1.fatTotalG }
    }
    
    var totalFiber: Double {
        mealsByType.values.flatMap { $0 }.reduce(0) { $0 + $1.fiberG }
    }
    
    var totalSugar: Double {
        mealsByType.values.flatMap { $0 }.reduce(0) { $0 + $1.sugarG }
    }
    
    var totalCholesterol: Int {
        mealsByType.values.flatMap { $0 }.reduce(0) { $0 + $1.cholesterolMg }
    }
    
    var totalSodium: Int {
        mealsByType.values.flatMap { $0 }.reduce(0) { $0 + $1.sodiumMg }
    }
    
    var totalPotassium: Int {
        mealsByType.values.flatMap { $0 }.reduce(0) { $0 + $1.potassiumMg }
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
                            if let mealsForType = mealsByType[mealType] {
                                NavigationLink {
                                    MealTypeDetailView(mealsType: mealType,
                                                       meals: mealsForType)
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
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        NutrientGridItem(title: "Fiber", value: totalFiber, unit: "g")
                        NutrientGridItem(title: "Sugar", value: totalSugar, unit: "g")
                        NutrientGridItem(title: "Cholesterol", value: Double(totalCholesterol), unit: "mg")
                        NutrientGridItem(title: "Sodium", value: Double(totalSodium), unit: "mg")
                        NutrientGridItem(title: "Potassium", value: Double(totalPotassium), unit: "mg")
                        NutrientGridItem(title: "Protein", value: Double(totalProtein), unit: "g")
                        NutrientGridItem(title: "Carbs", value: Double(totalCarbs), unit: "g")
                        NutrientGridItem(title: "Fat", value: Double(totalFat), unit: "g")
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
    
    var totalProtein: Double {
        meals.reduce(0) { $0 + $1.proteinG }
    }
    
    var totalCarbs: Double {
        meals.reduce(0) { $0 + $1.carbohydratesTotalG }
    }
    
    var totalFat: Double {
        meals.reduce(0) { $0 + $1.fatTotalG }
    }
    
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
                    Text("Total: P: \(Int(totalProtein))g, C: \(Int(totalCarbs))g, F: \(Int(totalFat))g")
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

struct MealTypeDetailView: View {
    var mealsType: MealTypes
    let meals: [FoodItem]
    
    var totalProtein: Double {
        meals.flatMap { $0 }.reduce(0) { $0 + $1.proteinG }
    }
    
    var totalCarbs: Double {
        meals.flatMap { $0 }.reduce(0) { $0 + $1.carbohydratesTotalG }
    }
    
    var totalFat: Double {
        meals.flatMap { $0 }.reduce(0) { $0 + $1.fatTotalG }
    }
    
    var totalFiber: Double {
        meals.flatMap { $0 }.reduce(0) { $0 + $1.fiberG }
    }
    
    var totalSugar: Double {
        meals.flatMap { $0 }.reduce(0) { $0 + $1.sugarG }
    }
    
    var totalCholesterol: Int {
        meals.flatMap { $0 }.reduce(0) { $0 + $1.cholesterolMg }
    }
    
    var totalSodium: Int {
        meals.flatMap { $0 }.reduce(0) { $0 + $1.sodiumMg }
    }
    
    var totalPotassium: Int {
        meals.flatMap { $0 }.reduce(0) { $0 + $1.potassiumMg }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("Foods")
                        .font(.dayDetailTitle)
                        .padding()
                        .navigationTitle(mealsType.mealName)
                    Spacer()
                }
                
                ForEach(meals, id: \.id) { meal in
                    NavigationLink {
                        FoodItemDetailView(food: meal)
                    } label: {
                        MealTypeDetailViewCell(meal: meal)
                    }
                }
                
                HStack {
                    Text("Nutrition")
                        .font(.dayDetailTitle)
                        .padding()
                        .navigationTitle(mealsType.mealName)
                    Spacer()
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    NutrientGridItem(title: "Fiber", value: totalFiber, unit: "g")
                    NutrientGridItem(title: "Sugar", value: totalSugar, unit: "g")
                    NutrientGridItem(title: "Cholesterol", value: Double(totalCholesterol), unit: "mg")
                    NutrientGridItem(title: "Sodium", value: Double(totalSodium), unit: "mg")
                    NutrientGridItem(title: "Potassium", value: Double(totalPotassium), unit: "mg")
                    NutrientGridItem(title: "Protein", value: Double(totalProtein), unit: "g")
                    NutrientGridItem(title: "Carbs", value: Double(totalCarbs), unit: "g")
                    NutrientGridItem(title: "Fat", value: Double(totalFat), unit: "g")
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
                    
                Text("\(meal.servingSizeG.formatted(.number)) gr.")
                    .font(.secondaryNumberTitle)
                    .foregroundStyle(Color.mealsDetailScreenSecondaryTitleColor)
            }
            Spacer()
        }
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
