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
        VStack(alignment: .leading) {
            foodEnteringTitle
            searchBar
            datePicker
            mealPicker
            Spacer()
            enteringButton
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
        .navigationTitle("Enter Food")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension SearchFoodView {
    private var foodEnteringTitle: some View {
        Text("What did you eat?")
            .font(.headerTitle)
            .padding([.vertical, .leading])
    }
    
    private var searchBar: some View {
        TextField("Type Your Meal", text: $typedMeal)
            .padding()
            .font(.primaryTitle)
            .foregroundStyle(Color.mealsDetailScreenSecondaryTitleColor)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.containerBackgroundColor)
            )
            .frame(height: 56)
            .padding(.horizontal)
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
        DatePicker(selection: $selectedDate, displayedComponents: [.date]) {
            Text("Pick your meal date")
        }
        .datePickerStyle(.compact)
        .tint(.appForegroundColor)
        .frame(height: 56)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.containerBackgroundColor)
        )
        .foregroundColor(Color.mealsDetailScreenSecondaryTitleColor) // Tarih yazısı rengi
        .padding(.horizontal)
        .font(.primaryTitle)
    }
    
    private var mealPicker: some View {
        Picker("Please select your meal", selection: $selectedMeal) {
            ForEach(MealTypes.allCases, id: \.self) {
                Text($0.mealName)
            }
        }
        .pickerStyle(.menu)
        .tint(.appForegroundColor)
        .frame(width: UIScreen.main.bounds.width * 0.85,
               height: 56)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.containerBackgroundColor)
        )
        .foregroundColor(Color.mealsDetailScreenSecondaryTitleColor) // Tarih yazısı rengi
        .padding(.horizontal)
        .font(.primaryTitle)
    }
    
    private var enteringButton: some View {
        Text("Next")
            .frame(width: UIScreen.main.bounds.width * 0.85)
            .frame(height: 48)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.confirmButtonBackgroudColor)
            )
            .foregroundColor(Color.appForegroundColor) // Tarih yazısı rengi
            .padding(.horizontal)
            .font(.confirmButtonTitle)
    }
}
