import Foundation

// Protocol for any data source that can provide meal type data
protocol MealTypeDataProvider {
    var mealType: MealTypes { get }
    var meals: [FoodItem] { get }
}

// Concrete implementation for direct data
struct MealTypeData: MealTypeDataProvider {
    let mealType: MealTypes
    let meals: [FoodItem]
    
    init(mealType: MealTypes, meals: [FoodItem]) {
        self.mealType = mealType
        self.meals = meals
    }
} 