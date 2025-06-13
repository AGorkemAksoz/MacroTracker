import Foundation

extension Array where Element == FoodItem {
    var totalProtein: Double {
        reduce(0) { $0 + $1.proteinG }
    }
    
    var totalCarbs: Double {
        reduce(0) { $0 + $1.carbohydratesTotalG }
    }
    
    var totalFat: Double {
        reduce(0) { $0 + $1.fatTotalG }
    }
    
    var totalFiber: Double {
        reduce(0) { $0 + $1.fiberG }
    }
    
    var totalSugar: Double {
        reduce(0) { $0 + $1.sugarG }
    }
    
    var totalCholesterol: Int {
        reduce(0) { $0 + $1.cholesterolMg }
    }
    
    var totalSodium: Int {
        reduce(0) { $0 + $1.sodiumMg }
    }
    
    var totalPotassium: Int {
        reduce(0) { $0 + $1.potassiumMg }
    }
    
    var totalCalories: Double {
        reduce(0) { $0 + $1.calories }
    }
}

extension Dictionary where Key == MealTypes, Value == [FoodItem] {
    var totalProtein: Double {
        values.flatMap { $0 }.totalProtein
    }
    
    var totalCarbs: Double {
        values.flatMap { $0 }.totalCarbs
    }
    
    var totalFat: Double {
        values.flatMap { $0 }.totalFat
    }
    
    var totalFiber: Double {
        values.flatMap { $0 }.totalFiber
    }
    
    var totalSugar: Double {
        values.flatMap { $0 }.totalSugar
    }
    
    var totalCholesterol: Int {
        values.flatMap { $0 }.totalCholesterol
    }
    
    var totalSodium: Int {
        values.flatMap { $0 }.totalSodium
    }
    
    var totalPotassium: Int {
        values.flatMap { $0 }.totalPotassium
    }
    
    var totalCalories: Double {
        values.flatMap { $0 }.totalCalories
    }
} 