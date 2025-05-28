import SwiftData
import Foundation

// MARK: - Container Protocol
protocol DependencyContainerProtocol {
    var nutritionService: NutritionServiceInterface { get }
    var databaseService: DatabaseServiceInterface { get }
    var modelContext: ModelContext { get }
    
    // Add factory method to protocol
    func makeHomeViewModel() -> HomeViewModel
}

// MARK: - Container Implementation
class DependencyContainer: DependencyContainerProtocol {
    let nutritionService: NutritionServiceInterface
    let databaseService: DatabaseServiceInterface
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.nutritionService = NutritionService()
        self.databaseService = NutritionDatabaseService(modelContext: modelContext)
    }
    
    // Factory method to create HomeViewModel
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            nutritionService: nutritionService,
            modelContext: modelContext,
            databaseService: databaseService
        )
    }
} 