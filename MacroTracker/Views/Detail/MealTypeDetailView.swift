//
//  MealTypeDetailView.swift
//  MacroTracker
//
//  Created by Gorkem on 13.06.2025.
//

import SwiftUI

struct MealTypeDetailView: View {
    let mealType: MealTypes
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @EnvironmentObject private var homeViewModel: HomeViewModel
    
    // Alert state
    @State private var showingDeleteAlert = false
    @State private var foodToDelete: FoodItem?
    
    init(mealsType: MealTypes, meals: [FoodItem]) {
        self.mealType = mealsType
    }
    
    // Computed property to get current meals for this meal type
    private var currentMeals: [FoodItem] {
        let mealsForDate = homeViewModel.getMealsForDate(homeViewModel.selectedDate)
        return mealsForDate.filter { $0.mealType == mealType }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Foods")
                    .padding()
                
                ForEach(currentMeals, id: \.id) { meal in
                    Button {
                        navigationCoordinator.navigate(to: .foodDetail(food: meal))
                    } label: {
                        IconCell(
                            iconName: mealType.iconName,
                            title: meal.name,
                            subtitle: "\(meal.servingSizeG.formatted(.number)) gr."
                        )
                    }
                    .contextMenu {
                        Button {
                            navigationCoordinator.navigate(to: .foodDetail(food: meal))
                        } label: {
                            Label("View Details", systemImage: "eye")
                        }
                        
                        Button(role: .destructive) {
                            showDeleteConfirmation(for: meal)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                
                SectionHeader(title: "Nutrition")
                    .padding()
                
                NutritionGrid(items: [
                    NutritionGridItem(title: "Fiber", value: currentMeals.totalFiber, unit: "g"),
                    NutritionGridItem(title: "Sugar", value: currentMeals.totalSugar, unit: "g"),
                    NutritionGridItem(title: "Cholesterol", value: Double(currentMeals.totalCholesterol), unit: "mg"),
                    NutritionGridItem(title: "Sodium", value: Double(currentMeals.totalSodium), unit: "mg"),
                    NutritionGridItem(title: "Potassium", value: Double(currentMeals.totalPotassium), unit: "mg"),
                    NutritionGridItem(title: "Protein", value: currentMeals.totalProtein, unit: "g"),
                    NutritionGridItem(title: "Carbs", value: currentMeals.totalCarbs, unit: "g"),
                    NutritionGridItem(title: "Fat", value: currentMeals.totalFat, unit: "g")
                ])
                .padding()
            }
            Spacer()
        }
        .navigationTitle(mealType.mealName)
        .confirmationAlert(
            isPresented: $showingDeleteAlert,
            alert: deleteConfirmationAlert
        )
    }
    
    // MARK: - Computed Properties
    
    private var deleteConfirmationAlert: ConfirmationAlert {
        ConfirmationAlert(
            title: "Delete Food",
            message: foodToDelete.map { "Are you sure you want to delete '\($0.name)'? This action cannot be undone." } ?? "",
            confirmButtonTitle: "Delete",
            cancelButtonTitle: "Cancel"
        ) {
            if let food = foodToDelete {
                deleteFood(food)
            }
            foodToDelete = nil
        }
    }
    
    // MARK: - Private Methods
    
    private func showDeleteConfirmation(for meal: FoodItem) {
        foodToDelete = meal
        showingDeleteAlert = true
    }
    
    private func deleteFood(_ meal: FoodItem) {
        // Delete the meal from the database
        homeViewModel.deleteFood(meal)
        // Refresh the home view model to update the UI
        homeViewModel.refreshSavedNutrition()
    }
}
