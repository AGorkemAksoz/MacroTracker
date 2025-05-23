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
    // Environment'dan ModelContext'i al
     @Environment(\.modelContext) private var modelContext
    
    @StateObject private var homeViewModel: HomeViewModel
    
    // Updating Init for init to modelContext
    init() {
        // ViewModel'i başlat, modelContext'i onAppear'da atayacağız
        let nutritionService = NutritionService()
        
        // Geçici ModelContext oluştur (daha sonra Environment'dan alınanla değiştirilecek)
        let tempModelContext = try! ModelContext(ModelContainer(for: FoodItem.self))
        let databaseService = NutritionDatabaseService(modelContext: tempModelContext)
        
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(
            nutritionService: nutritionService, modelContext: tempModelContext,
            databaseService: databaseService
        ))
    }
    
    @State private var selectedListType: HomeViewMacrosType = .list
    var body: some View {
        NavigationView {
            VStack {
                // SEGMENTED CONTROL
                Picker("View Type", selection: $selectedListType) {
                    Text("List").tag(HomeViewMacrosType.list )
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
                    SearchFoodView(homeViewModel: homeViewModel, modelContext: modelContext)
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(.blue)
                        .frame(width: 30, height: 30)
                }
            }
            .onAppear {
                // Environment'dan alınan modelContext'i ViewModel'e ata
                homeViewModel.updateModelContext(modelContext)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    HomeView()
}
