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
    
    @Environment(\.dismiss) var dismiss
    
    var modelContext: ModelContext
    
    var body: some View {
        VStack {
            searchBar
            DatePicker("Please pick your meal date", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(.compact)
                .onChange(of: selectedDate) { _, newValue in
                    print("Selected Date: \(newValue)")
                }
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
                    homeViewModel.savingNutritionToLocalDatabase(date: selectedDate)
                    homeViewModel.savedNutrititon = homeViewModel.fetchSavedFoods()
                }
//                dismiss()
            }
            .onChange(of: homeViewModel.isLoaded) { oldValue, newValue in
                if newValue {
                    dismiss()
                }
            }
            .onAppear {
                print(selectedDate)
            }
    }
}
