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
    @StateObject private var homeViewModel: HomeViewModel
    @State private var selectedListType: HomeViewMacrosType = .list
    
    // Initialize with dependency container
    init(dependencyContainer: DependencyContainerProtocol) {
        // Initialize ViewModel using the container
        _homeViewModel = StateObject(wrappedValue: dependencyContainer.makeHomeViewModel())
    }
    
    var mealsByDate: [Date: [FoodItem]] {
        Dictionary(grouping: homeViewModel.savedNutrititon, by: {$0.recordedDate})
    }
    
    var body: some View {
        NavigationView {
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
                            NavigationLink {
                                DailyMealDetailView()
                            } label:{
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                NavigationLink {
                    SearchFoodView(homeViewModel: homeViewModel)
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.appForegroundColor)
                        .frame(width: 24, height: 24)
                }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: FoodItem.self)
    let dependencyContainer = DependencyContainer(modelContext: container.mainContext)
    return HomeView(dependencyContainer: dependencyContainer)
}

/*
 
 //                // SEGMENTED CONTROL
 //                Picker("View Type", selection: $selectedListType) {
 //                    Text("List").tag(HomeViewMacrosType.list)
 //                    Text("Chart").tag(HomeViewMacrosType.pieChart)
 //                }
 //                .pickerStyle(SegmentedPickerStyle())
 //                .padding()
 //
 //                // SWITCH VIEW BASED ON SELECTED TYPE
 //                switch selectedListType {
 //                case .list:
 //                    FoodNutritionView(homeViewModel: homeViewModel, foods: $homeViewModel.savedNutrititon)
 //                case .pieChart:
 //                    WeeklySummaryView(homeViewModel: homeViewModel)
 //                }

 */

struct DailyMealDetailView: View {
    var body: some View {
        NavigationView {
            HStack {
                VStack {
                    Text("Meals")
                        .font(.dayDetailTitle)
                        .padding()
                    
                    HStack(alignment: .top, spacing: 16) {
                        Image("breakfastIcon")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.appForegroundColor)
                            .padding(12)
                            .background(Color.containerBackgroundColor)
                            .cornerRadius(8)
                            .padding(.leading)
                        
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Breakfast")
                                .font(.primaryTitle)
                                .foregroundStyle(Color.appForegroundColor)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Oatmeal: Protein: 10g, Carbs: 20g, Fats: 5g")
                                Text("Banana: Protein: 1g, Carbs: 27g, Fats: 0g")
                                Text("Almonds: Protein: 6g, Carbs: 6g, Fats: 14g")
                                Text("Protein: 17g, Carbs: 53g, Fats: 19g")
                            }
                            .font(.secondaryNumberTitle)
                            .foregroundStyle(Color.secondayNumberForegroundColor)
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
                .navigationTitle("Today").font(.headline)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
