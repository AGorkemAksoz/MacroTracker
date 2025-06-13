//
//  SearchFoodView.swift
//  MacroTracker
//
//  Created by Gorkem on 14.05.2025.
//

import SwiftData
import SwiftUI

struct EnteringFoodView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var typedMeal: String = "250 grams of chicken breast"
    @State private var selectedDate: Date = Date()
    @State private var selectedMeal: MealTypes = .breakfeast
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionHeader(title: "What did you eat?")
            
            SearchBar(
                placeholder: "Type Your Meal",
                text: $typedMeal,
                isLoading: homeViewModel.loadingState == .loading,
                onTextChange: { _ in
                    if case .error(let message) = homeViewModel.loadingState {
                        errorMessage = message
                        showError = true
                    }
                }
            )
            .disabled(homeViewModel.loadingState == .loading)
            
            DatePickerField(
                title: "Pick your meal date",
                date: $selectedDate
            )
            
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
    
    private var mealPicker: some View {
        Picker("Please select your meal", selection: $selectedMeal) {
            ForEach(MealTypes.allCases, id: \.self) {
                Text($0.mealName)
            }
        }
        .pickerStyle(.menu)
        .tint(.mealsDetailScreenSecondaryTitleColor)
        .frame(width: UIScreen.main.bounds.width * 0.85,
               height: 56,
               alignment: .leading)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.containerBackgroundColor)
        )
        .foregroundColor(Color.mealsDetailScreenSecondaryTitleColor)
        .padding(.horizontal)
        .font(.primaryTitle)
    }
    
    private var enteringButton: some View {
        Button {
            fetchNutrition()
        } label: {
            Text("Next")
                .frame(width: UIScreen.main.bounds.width * 0.85)
                .frame(height: 48)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.confirmButtonBackgroudColor)
                )
                .foregroundColor(Color.confirmButtonForegroudColor)
                .padding(.horizontal)
                .font(.confirmButtonTitle)
        }
        .disabled(homeViewModel.loadingState == .loading)
    }
    
    private func fetchNutrition() {
        homeViewModel.fetchNutrition(query: typedMeal) { result in
            switch result {
            case .success(_):
                navigationCoordinator.navigate(to: .confirmFood(
                    foods: homeViewModel.nutrition,
                    date: selectedDate,
                    mealType: selectedMeal
                ))
            case .failure(_):
                errorMessage = "Failed to fetch nutrition information"
                showError = true
            }
        }
    }
}
