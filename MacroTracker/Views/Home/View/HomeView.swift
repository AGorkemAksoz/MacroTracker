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
                            DailyMealCell(
                                date: date,
                                meals: homeViewModel.getMealsForDate(date)
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
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

struct DailyMealCell: View {
    let date: Date
    let meals: [FoodItem]
    
    var totalCalories: Double {
        meals.reduce(0) { $0 + $1.calories }
    }
    
    var totalProtein: Double {
        meals.reduce(0, {$0 + $1.proteinG})
    }
    
    var totalCarbs: Double {
        meals.reduce(0, {$0 + $1.carbohydratesTotalG})
    }
    
    var totalFat: Double {
        meals.reduce(0, {$0 + $1.fatTotalG})
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"  // Shows like "Mon, Jun 5"
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack {
            Image("dailyCellIcon")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.appForegroundColor)
                .padding(12)
                .background(Color.containerBackgroundColor)
                .cornerRadius(8)
                .padding(.leading)
            
            VStack(alignment: .leading) {
                Text(formattedDate)
                    .font(.primaryTitle)
                    .foregroundStyle(Color.appForegroundColor)
                
                Text("\(Int(totalCalories)) kcal | P: \(Int(totalProtein))g, C: \(Int(totalCarbs))g, F: \(Int(totalFat))g")
                    .font(.secondaryNumberTitle)
                    .foregroundStyle(Color.secondayNumberForegroundColor)
            }
        }
    }
}


/*
 HStack {
     Image("dailyCellIcon")
         .resizable()
         .frame(width: 24, height: 24)
         .foregroundStyle(Color.appForegroundColor)
         .padding(12)
         .background(Color.containerBackgroundColor)
         .cornerRadius(8)
         .padding(.leading)
     
     VStack(alignment: .leading) {
         Text("2 days ago")
             .font(.primaryTitle)
             .foregroundStyle(Color.appForegroundColor)
         
         Text("2000 kcal | P: 100g, C: 200g, F: 80g")
             .font(.secondaryNumberTitle)
             .foregroundStyle(Color.secondayNumberForegroundColor)
     }
 }
 
 HStack {
     Image("dailyCellIcon")
         .resizable()
         .frame(width: 24, height: 24)
         .foregroundStyle(Color.appForegroundColor)
         .padding(12)
         .background(Color.containerBackgroundColor)
         .cornerRadius(8)
         .padding(.leading)
     
     VStack(alignment: .leading) {
         Text("3 days ago")
             .font(.primaryTitle)
             .foregroundStyle(Color.appForegroundColor)
         
         Text("2000 kcal | P: 100g, C: 200g, F: 80g")
             .font(.secondaryNumberTitle)
             .foregroundStyle(Color.secondayNumberForegroundColor)
     }
 }
 
 HStack {
     Image("dailyCellIcon")
         .resizable()
         .frame(width: 24, height: 24)
         .foregroundStyle(Color.appForegroundColor)
         .padding(12)
         .background(Color.containerBackgroundColor)
         .cornerRadius(8)
         .padding(.leading)
     
     VStack(alignment: .leading) {
         Text("4 days ago")
             .font(.primaryTitle)
             .foregroundStyle(Color.appForegroundColor)
         
         Text("2000 kcal | P: 100g, C: 200g, F: 80g")
             .font(.secondaryNumberTitle)
             .foregroundStyle(Color.secondayNumberForegroundColor)
     }
 }
 
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
