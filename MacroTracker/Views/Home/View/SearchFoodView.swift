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
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            searchBar
            datePicker
            mealPicker
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
    }
}

extension SearchFoodView {
    private var searchBar: some View {
        TextField("Type Your Meal", text: $typedMeal)
            .padding()
            .border(.blue, width: 2)
            .frame(height: UIScreen.main.bounds.height * 0.2)
            .overlay {
                if case .loading = homeViewModel.loadingState {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .onSubmit {
                homeViewModel.processFoodEntry(
                    query: typedMeal,
                    date: selectedDate,
                    mealType: selectedMeal
                ) { success in
                    if success {
                        dismiss()
                    } else {
                        errorMessage = "Failed to process food entry. Please try again."
                        showError = true
                    }
                }
            }
            .onChange(of: homeViewModel.loadingState) { oldValue, newValue in
                if case .error(let message) = newValue {
                    errorMessage = message
                    showError = true
                }
            }
            .disabled(homeViewModel.loadingState == .loading)
    }
    
    private var datePicker: some View {
        DatePicker("Please pick your meal date", selection: $selectedDate, displayedComponents: [.date])
            .datePickerStyle(.compact)
            .padding()
    }
    
    private var mealPicker: some View {
        Picker("Please select your meal", selection: $selectedMeal) {
            ForEach(MealTypes.allCases, id: \.self) {
                Text($0.mealName)
            }
        }
        .pickerStyle(.navigationLink)
        .padding()
    }
}
