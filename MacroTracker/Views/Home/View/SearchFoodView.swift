//
//  SearchFoodView.swift
//  MacroTracker
//
//  Created by Gorkem on 14.05.2025.
//

import SwiftData
import SwiftUI

struct SearchFoodView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @State private var typedMeal: String = "250 grams of chicken breast"
    
    @Environment(\.dismiss) var dismiss
    
    var modelContext: ModelContext
    
    var body: some View {
        TextField("Type Your Meal", text: $typedMeal)
            .padding()
            .border(.blue, width: 2)
            .frame(height: UIScreen.main.bounds.height * 0.2)
            .onSubmit {
                homeViewModel.fetchNutrition(for: typedMeal)
//                dismiss()
            }
            .onChange(of: homeViewModel.isLoaded) { oldValue, newValue in
                if newValue {
                    dismiss()
                }
            }
    }
}
