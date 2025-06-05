//
//  HomeView.swift
//  MacroTracker
//
//  Created by Gorkem on 17.03.2025.
//

import SwiftData
import SwiftUI

enum HomeViewMacrosType: String {
    case list = "List"
    case pieChart = "Chart"
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var homeViewModel: HomeViewModel
    @State private var selectedListType: HomeViewMacrosType = .list
    
    // Initialize with dependency container
    init(dependencyContainer: DependencyContainerProtocol) {
        // Initialize ViewModel using the container
        _homeViewModel = StateObject(wrappedValue: dependencyContainer.makeHomeViewModel())
    }
    
    var mealsByDate: [Date: [FoodItem]] {
        Dictionary(grouping: homeViewModel.savedNutrititon, by: {$0.recordedDate})
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Today's Macros")
                                .font(.primaryTitle)
                            Text("\(Int(homeViewModel.totalCaloriesForSelectedDate)) kcal")
                                .font(.primaryNumberTitle)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .frame(height: UIScreen.main.bounds.height / 8)
                .frame(maxWidth: .infinity)
                .background(Color.containerBackgroundColor)
                .cornerRadius(8)
                .padding()
                
                Text("Previous Days")
                    .font(.headerTitle)
                    .padding()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(homeViewModel.getAllLoggedDates(), id: \.self) { date in
                            NavigationLink {
                                DailyMealDetailView(homeViewModel: homeViewModel, date: date)
                            } label:{
                                DailyMealCell(
                                    date: date,
                                    meals: homeViewModel.getMealsForDate(date)
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Macro Tracker").font(.headerTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                NavigationLink {
                    SearchFoodView(homeViewModel: homeViewModel)
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.appForegroundColor)
                        .frame(width: 24, height: 24)
                }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: FoodItem.self)
    let dependencyContainer = DependencyContainer(modelContext: container.mainContext)
    return HomeView(dependencyContainer: dependencyContainer)
}

/*
 
 //                // SEGMENTED CONTROL
 //                Picker("View Type", selection: $selectedListType) {
 //                    Text("List").tag(HomeViewMacrosType.list)
 //                    Text("Chart").tag(HomeViewMacrosType.pieChart)
 //                }
 //                .pickerStyle(SegmentedPickerStyle())
 //                .padding()
 //
 //                // SWITCH VIEW BASED ON SELECTED TYPE
 //                switch selectedListType {
 //                case .list:
 //                    FoodNutritionView(homeViewModel: homeViewModel, foods: $homeViewModel.savedNutrititon)
 //                case .pieChart:
 //                    WeeklySummaryView(homeViewModel: homeViewModel)
 //                }

 */

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
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Meals")
                                .font(.dayDetailTitle)
                                .padding()
                            
                            ForEach(MealTypes.allCases, id: \.self) { mealType in
                                if let mealsForType = mealsByType[mealType] {
                                    MealTypeSection(
                                        mealType: mealType,
                                        meals: mealsForType
                                    )
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
