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
    @State private var selectedMeal: MealTypes = .breakfast
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var searchQueryValidationErrors: [ValidationError] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionHeader(title: "What did you eat?")
                .padding(.leading)
            
            SearchBar(
                placeholder: "Type Your Meal",
                text: $typedMeal,
                isLoading: homeViewModel.loadingState == .loading,
                onTextChange: { _ in
                    validateSearchQuery()
                    if case .error(let message) = homeViewModel.loadingState {
                        errorMessage = message
                        showError = true
                    }
                }
            )
            .disabled(homeViewModel.loadingState == .loading)
            
            // Show validation errors
            if !searchQueryValidationErrors.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(searchQueryValidationErrors, id: \.errorDescription) { error in
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            
                            Text(error.errorDescription ?? "Validation error")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red.opacity(0.1))
                )
                .padding(.horizontal)
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .opacity
                ))
                .animation(.easeInOut(duration: 0.3), value: searchQueryValidationErrors.isEmpty)
            }
            
            DatePickerField(
                title: "Pick your meal date",
                date: $selectedDate
            )
            
            mealPicker
            
            Spacer()
            
            enteringButton
        }
        .opacity(homeViewModel.loadingState == .loading ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: homeViewModel.loadingState == .loading)
        .overlay {
            // Subtle loading indicator positioned appropriately
            if homeViewModel.loadingState == .loading {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 12) {
                            // Animated progress indicator
                            ZStack {
                                Circle()
                                    .stroke(Color.confirmButtonBackgroudColor.opacity(0.2), lineWidth: 4)
                                    .frame(width: 40, height: 40)
                                
                                Circle()
                                    .trim(from: 0, to: 0.7)
                                    .stroke(Color.confirmButtonBackgroudColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 40, height: 40)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: homeViewModel.loadingState == .loading)
                            }
                            
                            Text("Searching for nutrition data...")
                                .font(.secondaryNumberTitle)
                                .foregroundStyle(Color.secondayNumberForegroundColor)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.containerBackgroundColor)
                                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                        )
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .transition(.opacity.combined(with: .scale))
                .animation(.easeInOut(duration: 0.3), value: homeViewModel.loadingState == .loading)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
        .background(Color("appBackgroundColor").ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Enter Food")
                    .foregroundColor(.black)
            }
        }
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
            HStack(spacing: 12) {
                if homeViewModel.loadingState == .loading {
                    // Animated loading indicator
                    ZStack {
                        Circle()
                            .stroke(Color.confirmButtonForegroudColor.opacity(0.3), lineWidth: 2)
                            .frame(width: 20, height: 20)
                        
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(Color.confirmButtonForegroudColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 20, height: 20)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: homeViewModel.loadingState == .loading)
                    }
                    
                    Text("Searching...")
                        .font(.confirmButtonTitle)
                } else {
                    Text("Next")
                        .font(.confirmButtonTitle)
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.85)
            .frame(height: 48)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(homeViewModel.loadingState == .loading ? 
                          Color.confirmButtonBackgroudColor.opacity(0.7) : 
                          Color.confirmButtonBackgroudColor)
            )
            .foregroundColor(Color.confirmButtonForegroudColor)
            .padding(.horizontal)
            .scaleEffect(homeViewModel.loadingState == .loading ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: homeViewModel.loadingState == .loading)
        }
        .disabled(homeViewModel.loadingState == .loading)
        .opacity(homeViewModel.loadingState == .loading ? 0.8 : 1.0)
    }
    
    private func validateSearchQuery() {
        searchQueryValidationErrors = typedMeal.validateSearchQuery()
    }
    
    private func fetchNutrition() {
        // Validate before fetching
        let validationErrors = typedMeal.validateSearchQuery()
        if !validationErrors.isEmpty {
            searchQueryValidationErrors = validationErrors
            // Add haptic feedback for validation errors
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            return
        }
        
        // Add haptic feedback for successful button tap
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        homeViewModel.fetchNutrition(query: typedMeal) { result in
            switch result {
            case .success(_):
                // Add haptic feedback for success
                let successFeedback = UINotificationFeedbackGenerator()
                successFeedback.notificationOccurred(.success)
                
                navigationCoordinator.navigate(to: .confirmFood(
                    foods: homeViewModel.nutrition,
                    date: selectedDate,
                    mealType: selectedMeal
                ))
            case .failure(let error):
                // Add haptic feedback for error
                let errorFeedback = UINotificationFeedbackGenerator()
                errorFeedback.notificationOccurred(.error)
                
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}
