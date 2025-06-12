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
                ForEach(foods, id: \.name) { food in
                    ConfirmingFoodListCell(foodName: food.name ?? "Unknown Food",
                                           foodServingSize: String(food.servingSizeG ?? 0))
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
                    } label: {
                        Text("Confirm")
                            .font(.confirmViewEditButtonTitle)
                            .frame(width: 84, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.confirmButtonBackgroudColor)
                            )
                            .foregroundStyle(Color.confirmButtonForegroudColor)
                    }
                }

                Spacer()
            }
            .padding()
            .padding(.top, 8)
            .navigationTitle("Confirm Food")
            .navigationBarTitleDisplayMode(.inline)
            
            Spacer()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
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
