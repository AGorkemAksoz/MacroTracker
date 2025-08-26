//
//  ConfirmingFoodView.swift
//  MacroTracker
//
//  Created by Gorkem on 10.06.2025.
//

import SwiftUI

struct ConfirmingFoodView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    let foods: [Item]
    let consumedDate: Date
    let consumedMeal: MealTypes
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: consumedDate)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 24) {
                foodConfirmingTitle
                
                // Foods list
                if foods.isEmpty {
                    // Show message when no foods found
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title)
                            .foregroundColor(.orange)
                        
                        Text("No food data found")
                            .font(.primaryTitle)
                            .foregroundColor(.orange)
                        
                        Text("Please go back and try a different search term")
                            .font(.secondaryNumberTitle)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                } else {
                    // Show foods list
                    ForEach(foods, id: \.name) { food in
                        ConfirmingFoodListCell(foodName: food.name ?? "Unknown Food",
                                               foodServingSize: String(food.servingSizeG ?? 0))
                    }
                }
                
                // Date
                VStack(alignment: .leading, spacing: 24) {
                    Text("Date")
                        .font(.headerTitle)
                    Text(formattedDate)
                        .font(.foodDateLabel)
                }
                
                // Meal Type
                VStack(alignment: .leading, spacing: 24) {
                    Text("Meal Type")
                        .font(.headerTitle)
                    Text(consumedMeal.mealName)
                        .font(.foodDateLabel)
                }
                
                //Edit and Confirm Buttons
                HStack {
                    Button {
                        navigationCoordinator.navigateBack()
                    } label: {
                        Text("Edit")
                            .font(.confirmViewEditButtonTitle)
                            .frame(width: 84, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.containerBackgroundColor)
                            )
                            .foregroundStyle(Color.appForegroundColor)
                    }
                    
                    Spacer()
                    
                    Button {
                        if foods.isEmpty {
                            // Show alert for no food data
                            errorMessage = "No food data available. Please go back and try a different search term."
                            showError = true
                        } else {
                            // Process food entry
                            homeViewModel.processFoodEntry(items: foods,
                                                         date: consumedDate,
                                                         mealType: consumedMeal) { result in
                                if result {
                                    navigationCoordinator.navigateToRoot()
                                } else {
                                    errorMessage = "Failed to save food entry"
                                    showError = true
                                }
                            }
                        }
                    } label: {
                        Text("Confirm")
                            .font(.confirmViewEditButtonTitle)
                            .frame(width: 84, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(foods.isEmpty ? Color.gray : Color.tabBarTintColor)
                            )
                            .foregroundStyle(Color.confirmButtonForegroudColor)
                    }
                    .disabled(foods.isEmpty) // Disable button when no foods
                }

                Spacer()
            }
            .padding()
            .padding(.top, 8)
            
            Spacer()
        }
        .alert("No Food Data", isPresented: $showError) {
            Button("Go Back") { 
                showError = false
                navigationCoordinator.navigateBack()
            }
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
        .foregroundStyle(Color.appTitleTintColor)
        .background(Color("appBackgroundColor").ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Confirm Food")
                    .foregroundColor(.black)
            }
        }
    }
}

extension ConfirmingFoodView {
    private var foodConfirmingTitle: some View {
        Text("Meal Details")
            .font(.headerTitle)
    }
}


struct ConfirmingFoodListCell: View {
    let foodName: String
    let foodServingSize: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(foodName)
                .font(.primaryTitle)
                .foregroundStyle(Color.appForegroundColor)
            Text("\(foodServingSize) gr")
                .font(.secondaryNumberTitle)
                .foregroundStyle(Color.secondayNumberForegroundColor)
        }
    }
}
