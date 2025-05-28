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
    @State private var selectedDate: Date = Date()
    @State private var selectedMeal: MealTypes = .breakfeast
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            searchBar
            datePicker
            mealPicker
        }
    }
}

extension SearchFoodView {
    private var searchBar: some View {
        TextField("Type Your Meal", text: $typedMeal)
            .padding()
            .border(.blue, width: 2)
            .frame(height: UIScreen.main.bounds.height * 0.2)
            .onSubmit {
                homeViewModel.fetchNutrition(for: typedMeal) {
                    homeViewModel.savingNutritionToLocalDatabase(date: selectedDate,
                                                              meal: selectedMeal)
                    homeViewModel.savedNutrititon = homeViewModel.fetchSavedFoods()
                }
            }
            .onChange(of: homeViewModel.isLoaded) { oldValue, newValue in
                if newValue {
                    dismiss()
                }
            }
    }
    
    private var datePicker: some View {
        DatePicker("Please pick your meal date", selection: $selectedDate, displayedComponents: [.date])
            .datePickerStyle(.compact)
    }
    
    private var mealPicker: some View {
        Picker("Please select your meal", selection: $selectedMeal) {
            ForEach(MealTypes.allCases, id: \.self) {
                Text($0.mealName)
            }
        }
        .pickerStyle(.navigationLink)
    }
}
