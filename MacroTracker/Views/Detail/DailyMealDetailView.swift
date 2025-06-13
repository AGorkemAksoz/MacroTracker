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
                SectionHeader(title: "Meals")
                    .padding()
                
                ForEach(MealTypes.allCases, id: \.self) { mealType in
                    if let mealsForType = data.getMealsByType(for: date)[mealType] {
                        Button {
                            navigationCoordinator.navigate(to: .mealTypeDetail(type: mealType, meals: mealsForType))
                        } label: {
                            MealTypeCell(mealType: mealType, meals: mealsForType)
                        }
                    }
                }
                
                SectionHeader(title: "Daily Summary")
                    .padding()
                
                let mealsByType = data.getMealsByType(for: date)
                NutritionGrid(items: [
                    NutritionGridItem(title: "Fiber", value: mealsByType.totalFiber, unit: "g"),
                    NutritionGridItem(title: "Sugar", value: mealsByType.totalSugar, unit: "g"),
                    NutritionGridItem(title: "Cholesterol", value: Double(mealsByType.totalCholesterol), unit: "mg"),
                    NutritionGridItem(title: "Sodium", value: Double(mealsByType.totalSodium), unit: "mg"),
                    NutritionGridItem(title: "Potassium", value: Double(mealsByType.totalPotassium), unit: "mg"),
                    NutritionGridItem(title: "Protein", value: mealsByType.totalProtein, unit: "g"),
                    NutritionGridItem(title: "Carbs", value: mealsByType.totalCarbs, unit: "g"),
                    NutritionGridItem(title: "Fat", value: mealsByType.totalFat, unit: "g")
                ])
                .padding()
                
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
