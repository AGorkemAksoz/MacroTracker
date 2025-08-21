//
//  MealTypeDetailView.swift
//  MacroTracker
//
//  Created by Gorkem on 13.06.2025.
//

import SwiftUI

struct MealTypeDetailView: View {
    let mealType: MealTypes
    let date: Date  // Added date parameter
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @EnvironmentObject private var homeViewModel: HomeViewModel
    
    // Alert state
    @State private var showingDeleteAlert = false
    @State private var foodToDelete: FoodItem?
    
    init(mealsType: MealTypes, meals: [FoodItem], date: Date) {  // Updated initializer
        self.mealType = mealsType
        self.date = date
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Foods")
                    .padding(.leading)
                
                ForEach(homeViewModel.getFoodsByDate(date, for: mealType), id: \.id) { meal in
                    Button {
                        navigationCoordinator.navigate(to: .foodDetail(food: meal))
                    } label: {
                        IconCell(
                            iconName: mealType.iconName,
                            title: meal.name,
                            subtitle: "\(meal.servingSizeG.formatted(.number)) gr."
                        )
                    }
                    .contextMenu(item: meal,
                                 actions: [
                                    ViewDetailsAction(),
                                    DeleteAction(title: "Delete Food")
                                 ],
                                 onAction: { action, meal in
                        switch action {
                        case is ViewDetailsAction:
                            navigationCoordinator.navigate(to: .foodDetail(food: meal))
                        case is DeleteAction:
                            showDeleteConfirmation(for: meal)
                        default:
                            break
                        }
                    })
                }
                
                SectionHeader(title: "Nutrition")
                    .padding()
                
                NutritionGrid(items: [
                    NutritionGridItem(title: "Fiber", value: homeViewModel.getFoodsByDate(date, for: mealType).totalFiber, unit: "g"),
                    NutritionGridItem(title: "Sugar", value: homeViewModel.getFoodsByDate(date, for: mealType).totalSugar, unit: "g"),
                    NutritionGridItem(title: "Cholesterol", value: Double(homeViewModel.getFoodsByDate(date, for: mealType).totalCholesterol), unit: "mg"),
                    NutritionGridItem(title: "Sodium", value: Double(homeViewModel.getFoodsByDate(date, for: mealType).totalSodium), unit: "mg"),
                    NutritionGridItem(title: "Potassium", value: Double(homeViewModel.getFoodsByDate(date, for: mealType).totalPotassium), unit: "mg"),
                    NutritionGridItem(title: "Protein", value: homeViewModel.getFoodsByDate(date, for: mealType).totalProtein, unit: "g"),
                    NutritionGridItem(title: "Carbs", value: homeViewModel.getFoodsByDate(date, for: mealType).totalCarbs, unit: "g"),
                    NutritionGridItem(title: "Fat", value: homeViewModel.getFoodsByDate(date, for: mealType).totalFat, unit: "g")
                ])
                .padding()
            }
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(mealType.mealName)
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
        
        foodToDelete = nil
        
        homeViewModel.refreshSavedNutrition()
    }
}
