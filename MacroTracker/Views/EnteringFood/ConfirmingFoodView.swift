//
//  ConfirmingFoodView.swift
//  MacroTracker
//
//  Created by Gorkem on 10.06.2025.
//

import SwiftUI

struct ConfirmingFoodView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 24) {
                foodConfirmingTitle
                // Foods list
                VStack(alignment: .leading, spacing: 4) {
                    Text("Chicken Breast")
                        .font(.primaryTitle)
                        .foregroundStyle(Color.appForegroundColor)
                    Text("200g")
                        .font(.secondaryNumberTitle)
                        .foregroundStyle(Color.secondayNumberForegroundColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Brown Rice")
                        .font(.primaryTitle)
                        .foregroundStyle(Color.appForegroundColor)
                    Text("150g")
                        .font(.secondaryNumberTitle)
                        .foregroundStyle(Color.secondayNumberForegroundColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Broccoli")
                        .font(.primaryTitle)
                        .foregroundStyle(Color.appForegroundColor)
                    Text("100g")
                        .font(.secondaryNumberTitle)
                        .foregroundStyle(Color.secondayNumberForegroundColor)
                }
                
                // Date
                VStack(alignment: .leading, spacing: 24) {
                    Text("Date")
                        .font(.headerTitle)
                    Text("July 24, 1994")
                        .font(.foodDateLabel)
                }
                
                // Meal Type
                VStack(alignment: .leading, spacing: 24) {
                    Text("Meal Type")
                        .font(.headerTitle)
                    Text("Dinner")
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
                        print("Confirm Button Tapped!!!")
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

#Preview {
    ConfirmingFoodView()
}

extension ConfirmingFoodView {
    private var foodConfirmingTitle: some View {
        Text("Meal Details")
            .font(.headerTitle)
    }
}
