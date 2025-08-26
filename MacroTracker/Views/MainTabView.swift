//
//  MainTabView.swift
//  MacroTracker
//
//  Created by Gorkem on 25.02.2025.
//

import Combine
import SwiftUI
import SwiftData

struct MainTabView: View {
    let dependencyContainer: DependencyContainerProtocol
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    @StateObject private var sharedHomeViewModel: HomeViewModel
    
    init(dependencyContainer: DependencyContainerProtocol) {
        self.dependencyContainer = dependencyContainer
        _sharedHomeViewModel = StateObject(wrappedValue: dependencyContainer.makeHomeViewModel())
    }
    
    var body: some View {
        TabView {
            HomeView(homeViewModel: sharedHomeViewModel)
                .tabItem {
                    Image(systemName: "house")
                    Text("Dashboard")
                }
                .environmentObject(navigationCoordinator)
            
            ChartsView(dependencyContainer: dependencyContainer, homeViewModel: sharedHomeViewModel)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Progress")
                }
        }
        .tint(Color.tabBarTintColor)
    }
}

#if DEBUG
// Mock implementations for preview
class MockNutritionRepository: NutritionRepositoryInterface {
    func getAllFoodItems() -> [FoodItem] { [] }
    func getFoodItems(for date: Date) -> [FoodItem] { [] }
    func saveFoodItems(_ items: [Item], date: Date, mealType: MealTypes) -> Bool { true }
    func deleteFoodItem(_ foodItem: FoodItem) {}
    func deleteAllFoodsForMealTypeAndDate(mealType: MealTypes, date: Date) {}
    func searchNutrition(query: String) -> AnyPublisher<[Item], Error> { Just([]).setFailureType(to: Error.self).eraseToAnyPublisher() }
}

class MockDependencyContainer: DependencyContainerProtocol {
    let nutritionRepository: NutritionRepositoryInterface = MockNutritionRepository()
    let modelContext: ModelContext
    init(modelContext: ModelContext) { self.modelContext = modelContext }
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(nutritionRepository: nutritionRepository, modelContext: modelContext)
    }
    
    func makeProgressViewModel(homeViewModel: HomeViewModel) -> ProgressViewModel {
        let dataService = ConcreteProgressDataService(homeViewModel: homeViewModel)
        let calculationService = ConcreteProgressCalculationService()
        return ProgressViewModel(dataService: dataService, calculationService: calculationService)
    }
}
#endif

#Preview {
#if DEBUG
    let schema = Schema([FoodItem.self])
    let modelConfig = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [modelConfig])
    let dependencyContainer = MockDependencyContainer(modelContext: container.mainContext)
    return MainTabView(dependencyContainer: dependencyContainer)
#else
    EmptyView()
#endif
} 
