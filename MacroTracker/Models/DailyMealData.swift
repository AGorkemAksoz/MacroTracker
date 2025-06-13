import Foundation

// Protocol for any data source that can provide daily meal data
protocol DailyMealDataProvider {
    func getMealsByType(for date: Date) -> [MealTypes: [FoodItem]]
}

// Concrete implementation for HomeViewModel
extension HomeViewModel: DailyMealDataProvider {
    // HomeViewModel already has getMealsByType method, so no need to implement it
}

// Data structure to hold daily meal data
struct DailyMealData: DailyMealDataProvider {
    let date: Date
    private let mealsByType: [MealTypes: [FoodItem]]
    
    // Helper initializer from HomeViewModel
    init(date: Date, homeViewModel: HomeViewModel) {
        self.date = date
        self.mealsByType = homeViewModel.getMealsByType(for: date)
    }
    
    // Helper initializer for direct data
    init(date: Date, mealsByType: [MealTypes: [FoodItem]]) {
        self.date = date
        self.mealsByType = mealsByType
    }
    
    // Protocol conformance
    func getMealsByType(for date: Date) -> [MealTypes: [FoodItem]] {
        return mealsByType
    }
} 