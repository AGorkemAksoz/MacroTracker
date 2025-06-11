//
//  ConfirmingFoodView.swift
//  MacroTracker
//
//  Created by Gorkem on 10.06.2025.
//

import SwiftUI

struct ConfirmingFoodView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss
    
    var foods: [Item]
    var consumedDate: Date
    var consumedMeal: MealTypes
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"  // Shows like "Mon, Jun 5"
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
                        print("Edit Button Tapped!!!")
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
                            switch result {
                            case true:
                                dismiss()
                            case false:
                                print("Get yourself look what you're doing")
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
