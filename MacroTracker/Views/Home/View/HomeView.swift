//
//  HomeView.swift
//  MacroTracker
//
//  Created by Gorkem on 17.03.2025.
//

import SwiftData
import SwiftUI

enum HomeViewMacrosType: String {
    case list = "List"
    case pieChart = "Chart"
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var homeViewModel: HomeViewModel
    @State private var selectedListType: HomeViewMacrosType = .list
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    
    // Initialize with shared HomeViewModel
    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
    }
    
    // Legacy initializer for backwards compatibility
    init(dependencyContainer: DependencyContainerProtocol) {
        self.homeViewModel = dependencyContainer.makeHomeViewModel()
    }
    
    var mealsByDate: [Date: [FoodItem]] {
        Dictionary(grouping: homeViewModel.savedNutrititon, by: {$0.recordedDate})
    }
    
    var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
            VStack(alignment: .leading) {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Today's Macros")
                                .font(.primaryTitle)
                            Text("\(Int(homeViewModel.totalCaloriesForSelectedDate)) kcal")
                                .font(.primaryNumberTitle)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .frame(height: UIScreen.main.bounds.height / 8)
                .frame(maxWidth: .infinity)
                .background(Color.containerBackgroundColor)
                .cornerRadius(8)
                .padding()
                
                Text("Previous Days")
                    .font(.headerTitle)
                    .padding()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(homeViewModel.getAllLoggedDates(), id: \.self) { date in
                            Button {
                                navigationCoordinator.navigate(to: .dailyMealDetail(date: date))
                            } label: {
                                DailyMealCell(
                                    date: date,
                                    meals: homeViewModel.getMealsForDate(date)
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Macro Tracker").font(.headerTitle)
            .navigationBarTitleDisplayMode(.large)
            .foregroundStyle(Color.appTitleTintColor)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        navigationCoordinator.navigate(to: .enterFood)
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.appForegroundColor)
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .background(Color("appBackgroundColor").ignoresSafeArea())
            .navigationDestination(for: AppRoute.self) { route in
                Group {
                    switch route {
                    case .home:
                        HomeView(homeViewModel: homeViewModel)
                    case .enterFood:
                        EnteringFoodView(homeViewModel: homeViewModel)
                    case .confirmFood(let foods, let date, let mealType):
                        ConfirmingFoodView(
                            homeViewModel: homeViewModel,
                            foods: foods,
                            consumedDate: date,
                            consumedMeal: mealType
                        )
                    case .dailyMealDetail(let date):
                        DailyMealDetailView(date: date, homeViewModel: homeViewModel)
                    case .mealTypeDetail(let type, let meals, let date):
                        MealTypeDetailView(mealsType: type, meals: meals, date: date)
                            .environmentObject(homeViewModel)
                    case .foodDetail(let food):
                        FoodDetailView(foodItem: food)
                    }
                }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: FoodItem.self)
    let dependencyContainer = DependencyContainer(modelContext: container.mainContext)
    let homeViewModel = dependencyContainer.makeHomeViewModel()
    return HomeView(homeViewModel: homeViewModel)
}
