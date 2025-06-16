import Combine
import SwiftUI
import SwiftData

struct MainTabView: View {
    let dependencyContainer: DependencyContainerProtocol
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    
    var body: some View {
        TabView {
            HomeView(dependencyContainer: dependencyContainer)
                .tabItem {
                    Image(systemName: "house")
                    Text("Dashboard")
                }
                .environmentObject(navigationCoordinator)
            
            ChartsView(homeViewModel: dependencyContainer.makeHomeViewModel())
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Progress")
                }
        }
    }
}

#if DEBUG
// Mock implementations for preview
class MockNutritionRepository: NutritionRepositoryInterface {
    func getAllFoodItems() -> [FoodItem] { [] }
    func getFoodItems(for date: Date) -> [FoodItem] { [] }
    func saveFoodItems(_ items: [Item], date: Date, mealType: MealTypes) -> Bool { true }
    func deleteFoodItem(_ foodItem: FoodItem) {}
    func searchNutrition(query: String) -> AnyPublisher<[Item], Error> { Just([]).setFailureType(to: Error.self).eraseToAnyPublisher() }
}

class MockDependencyContainer: DependencyContainerProtocol {
    let nutritionRepository: NutritionRepositoryInterface = MockNutritionRepository()
    let modelContext: ModelContext
    init(modelContext: ModelContext) { self.modelContext = modelContext }
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(nutritionRepository: nutritionRepository, modelContext: modelContext)
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
