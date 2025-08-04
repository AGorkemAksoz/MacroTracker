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
    @ObservedObject var homeViewModel: HomeViewModel
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    
    // Alert state for delete functionality
    @State private var showingDeleteAlert = false
    @State private var mealTypeToDelete: MealTypes?
    
    init(data: DailyMealDataProvider, date: Date) {
        self.data = data
        self.date = date
        // We need to handle this case - either make homeViewModel optional or provide a default
        if let homeVM = data as? HomeViewModel {
            self.homeViewModel = homeVM
        } else {
            // This should not happen in normal usage, but we need to provide a fallback
            fatalError("DailyMealDetailView requires HomeViewModel as data provider")
        }
        
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    // Convenience initializer for HomeViewModel
    init(date: Date, homeViewModel: HomeViewModel) {
        self.data = homeViewModel
        self.date = date
        self.homeViewModel = homeViewModel
        
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                SectionHeader(title: "Meals")
                    .padding([.leading, .bottom])
                
                // Use homeViewModel directly to ensure reactivity
                ForEach(MealTypes.allCases, id: \.self) { mealType in
                    let mealsForType = homeViewModel.getMealsByType(for: date)[mealType] ?? []
                    
                    if !mealsForType.isEmpty {
                        Button {
                            navigationCoordinator.navigate(to: .mealTypeDetail(type: mealType, meals: mealsForType, date: date))
                        } label: {
                            MealTypeCell(mealType: mealType, meals: mealsForType)
                        }
                        .contextMenu(item: mealType,
                                            actions: [
                                                    ViewDetailsAction(),
                                                    DeleteAction(title: "Delete All Foods")
                                                 ],
                                                 onAction: { action, mealType in
                            switch action {
                            case is ViewDetailsAction:
                                navigationCoordinator.navigate(to: .mealTypeDetail(type: mealType, meals: mealsForType, date: date))
                            case is DeleteAction:
                                showDeleteConfirmation(for: mealType)
                            default:
                                break
                            }
                        })
                    }
                }
                
                SectionHeader(title: "Daily Summary")
                    .padding()
                
                // Use homeViewModel directly for reactive updates
                let mealsByType = homeViewModel.getMealsByType(for: date)
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(formatDate(date))
                    .foregroundColor(.black)
            }
        }
        .background(Color("appBackgroundColor").ignoresSafeArea())
        .confirmationAlert(
            isPresented: $showingDeleteAlert,
            alert: deleteConfirmationAlert
        )
    }
    
    // MARK: - Computed Properties
    
    private var deleteConfirmationAlert: ConfirmationAlert {
        ConfirmationAlert(
            title: "Delete All Foods",
            message: mealTypeToDelete.map { "Are you sure you want to delete all foods from '\($0.mealName)'? This action cannot be undone." } ?? "",
            confirmButtonTitle: "Delete",
            cancelButtonTitle: "Cancel"
        ) {
            if let mealType = mealTypeToDelete {
                deleteAllFoodsForMealType(mealType)
            }
            mealTypeToDelete = nil
        }
    }
    
    // MARK: - Private Methods
    
    private func showDeleteConfirmation(for mealType: MealTypes) {
        mealTypeToDelete = mealType
        showingDeleteAlert = true
    }
    
    private func deleteAllFoodsForMealType(_ mealType: MealTypes) {
        // Get all foods for this meal type and date
        let foodsToDelete = homeViewModel.getFoodsByDate(date, for: mealType)
        
        // Create a set of unique IDs to avoid deleting the same object multiple times
        let uniqueFoodIds = Set(foodsToDelete.map { $0.id })
        
        // Delete each unique food item
        for foodId in uniqueFoodIds {
            if let food = foodsToDelete.first(where: { $0.id == foodId }) {
                homeViewModel.deleteFood(food)
            }
        }
        
        mealTypeToDelete = nil
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

