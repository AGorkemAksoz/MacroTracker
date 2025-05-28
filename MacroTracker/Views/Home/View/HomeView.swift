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
    
    var body: some View {
        NavigationView {
            VStack {
                // SEGMENTED CONTROL
                Picker("View Type", selection: $selectedListType) {
                    Text("List").tag(HomeViewMacrosType.list)
                    Text("Chart").tag(HomeViewMacrosType.pieChart)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // SWITCH VIEW BASED ON SELECTED TYPE
                switch selectedListType {
                case .list:
                    FoodNutritionView(homeViewModel: homeViewModel, foods: $homeViewModel.savedNutrititon)
                case .pieChart:
                    PieChartView(macros: [
                        Macro(name: "Protein", value: homeViewModel.totalProtein, color: .blue),
                        Macro(name: "Fat", value: homeViewModel.totalFat, color: .orange),
                        Macro(name: "Carbs", value: homeViewModel.totalCarbs, color: .red),
                        Macro(name: "Sugar", value: homeViewModel.totalSugar, color: .brown)
                    ])
                }
                Spacer()
            }
            .navigationTitle("Macro Tracker")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                NavigationLink {
                    SearchFoodView(homeViewModel: homeViewModel)
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(.blue)
                        .frame(width: 30, height: 30)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    let container = try! ModelContainer(for: FoodItem.self)
    let dependencyContainer = DependencyContainer(modelContext: container.mainContext)
    return HomeView(dependencyContainer: dependencyContainer)
}
