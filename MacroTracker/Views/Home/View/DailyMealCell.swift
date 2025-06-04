//
//  DailyMealCell.swift
//  MacroTracker
//
//  Created by Ali Görkem Aksöz on 4.06.2025.
//

import SwiftUI

struct DailyMealCell: View {
    let date: Date
    let meals: [FoodItem]
    
    var totalCalories: Double {
        meals.reduce(0) { $0 + $1.calories }
    }
    
    var totalProtein: Double {
        meals.reduce(0, {$0 + $1.proteinG})
    }
    
    var totalCarbs: Double {
        meals.reduce(0, {$0 + $1.carbohydratesTotalG})
    }
    
    var totalFat: Double {
        meals.reduce(0, {$0 + $1.fatTotalG})
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"  // Shows like "Mon, Jun 5"
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack {
            Image("dailyCellIcon")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.appForegroundColor)
                .padding(12)
                .background(Color.containerBackgroundColor)
                .cornerRadius(8)
                .padding(.leading)
            
            VStack(alignment: .leading) {
                Text(formattedDate)
                    .font(.primaryTitle)
                    .foregroundStyle(Color.appForegroundColor)
                
                Text("\(Int(totalCalories)) kcal | P: \(Int(totalProtein))g, C: \(Int(totalCarbs))g, F: \(Int(totalFat))g")
                    .font(.secondaryNumberTitle)
                    .foregroundStyle(Color.secondayNumberForegroundColor)
            }
        }
    }
}
