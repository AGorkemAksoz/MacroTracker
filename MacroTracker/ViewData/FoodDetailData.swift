import Foundation

// Protocol for any data source that can provide food detail data
protocol FoodDetailDataProvider {
    var name: String { get }
    var mealType: MealTypes { get }
    var recordedDate: Date { get }
    var calories: Double { get }
    var servingSizeG: Double { get }
    var proteinG: Double { get }
    var carbohydratesTotalG: Double { get }
    var fatTotalG: Double { get }
    var fiberG: Double { get }
    var sugarG: Double { get }
    var cholesterolMg: Int { get }
    var sodiumMg: Int { get }
    var potassiumMg: Int { get }
    var fatSaturatedG: Double { get }
}

// Concrete implementation for FoodItem
extension FoodItem: FoodDetailDataProvider {
    // FoodItem already has all the required properties, so no need to implement anything
} 