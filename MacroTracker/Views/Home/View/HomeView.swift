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
                                DailyMealDetailView(homeViewModel: homeViewModel, date: date)
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
                    EnteringFoodView(homeViewModel: homeViewModel)
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
