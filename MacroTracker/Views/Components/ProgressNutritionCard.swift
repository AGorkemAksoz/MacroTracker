//
//  ProgressNutritionCard.swift
//  MacroTracker
//
//  Created by Gorkem on 20.05.2025.
//

import SwiftUI

struct ProgressNutritionCard: View {
    let title: String
    let value: String
    let change: Int
    let comparisonLabel: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.primaryTitle)
            
            Text(value)
                .font(.primaryNumberTitle)
            
            HStack(spacing: 4) {
                Text(comparisonLabel)
                    .font(.secondaryNumberTitle)
                    .foregroundStyle(Color.secondayNumberForegroundColor)
                
                Text("\(change > 0 ? "+" : "")\(change)%")
                    .font(.secondaryNumberTitle)
                    .foregroundStyle(change >= 0 ? Color.green : Color.red)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Convenience Initializers

extension ProgressNutritionCard {
    init(title: String, value: Int, unit: String = "", change: Int, comparisonLabel: String) {
        self.title = title
        self.value = unit.isEmpty ? "\(value)" : "\(value)\(unit)"
        self.change = change
        self.comparisonLabel = comparisonLabel
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressNutritionCard(
            title: "Calories",
            value: "2,150",
            change: 12,
            comparisonLabel: "vs Last 7 Days"
        )
        
        ProgressNutritionCard(
            title: "Protein",
            value: 125,
            unit: "g",
            change: -5,
            comparisonLabel: "vs Last 7 Days"
        )
        
        ProgressNutritionCard(
            title: "Fat",
            value: 80,
            unit: "g",
            change: 0,
            comparisonLabel: "vs Last Month"
        )
    }
    .padding()
} 
