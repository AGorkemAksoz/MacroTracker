import SwiftData
import Foundation

/// A comprehensive guide to Dependency Injection in this app
///
/// # What is Dependency Injection?
/// Dependency Injection (DI) is a design pattern where a class receives its dependencies
/// from external sources rather than creating them internally. This promotes:
/// - Loose coupling between classes
/// - Better testability
/// - More flexible and maintainable code
///
/// # How it works in this app:
/// 1. Services are defined by protocols (e.g., `NutritionServiceInterface`)
/// 2. The container holds concrete implementations of these services
/// 3. Views and ViewModels receive their dependencies through constructor injection
///
/// # Usage Example:
/// ```swift
/// // Create the container
/// let container = DependencyContainer(modelContext: context)
///
/// // Use the container to create a view
/// let homeView = HomeView(dependencyContainer: container)
/// ```
///
/// # Benefits:
/// - **Testability**: Easy to swap real implementations with mocks
/// - **Maintainability**: Dependencies are managed in one central place
/// - **Flexibility**: Easy to change implementations without affecting dependent code
/// - **Single Responsibility**: Each class focuses on its core functionality
protocol DependencyContainerProtocol {
    /// The repository responsible for all nutrition-related data operations
    var nutritionRepository: NutritionRepositoryInterface { get }
    
    /// The SwiftData context for managing persistent data
    var modelContext: ModelContext { get }
    
    /// Creates a new instance of HomeViewModel with all required dependencies
    /// - Returns: A configured HomeViewModel instance
    func makeHomeViewModel() -> HomeViewModel
}

/// The concrete implementation of the dependency container
///
/// This class is responsible for:
/// 1. Creating and configuring all service instances
/// 2. Providing factory methods for ViewModels
/// 3. Managing the lifecycle of dependencies
///
/// # Example Usage:
/// ```swift
/// let container = DependencyContainer(modelContext: context)
/// let viewModel = container.makeHomeViewModel()
/// ```
class DependencyContainer: DependencyContainerProtocol {
    /// The nutrition service instance used throughout the app
    private let nutritionService: NutritionServiceInterface
    
    /// The database service instance used throughout the app
    private let databaseService: DatabaseServiceInterface
    
    /// The cache service instance used throughout the app
    private let cacheService: NutritionCacheServiceInterface
    
    /// The repository responsible for all nutrition-related data operations
    let nutritionRepository: NutritionRepositoryInterface
    
    /// The shared ModelContext instance
    let modelContext: ModelContext
    
    /// Initializes a new dependency container
    /// - Parameter modelContext: The SwiftData context to use for database operations
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        // Create concrete implementations of services
        self.nutritionService = NutritionService()
        self.databaseService = NutritionDatabaseService(modelContext: modelContext)
        self.cacheService = NutritionCacheService()
        // Create repository with its dependencies
        self.nutritionRepository = NutritionRepository(
            nutritionService: nutritionService,
            databaseService: databaseService,
            cacheService: cacheService
        )
    }
    
    /// Creates a new HomeViewModel with all its required dependencies
    /// - Returns: A fully configured HomeViewModel instance
    ///
    /// This factory method ensures that HomeViewModel receives all its
    /// required dependencies in a properly configured state.
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            nutritionRepository: nutritionRepository,
            modelContext: modelContext
        )
    }
} 