import Foundation

// MARK: - Validation Errors
enum ValidationError: LocalizedError {
    case invalidCalories(Double)
    case invalidProtein(Double)
    case invalidCarbs(Double)
    case invalidFat(Double)
    case invalidServingSize(Double)
    case invalidSodium(Int)
    case invalidPotassium(Int)
    case invalidCholesterol(Int)
    case invalidFiber(Double)
    case invalidSugar(Double)
    case invalidName(String)
    case emptySearchQuery
    case searchQueryTooShort(String)
    case searchQueryTooLong(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCalories(let value):
            return "Invalid calories: \(value). Must be between 0 and 10,000."
        case .invalidProtein(let value):
            return "Invalid protein: \(value)g. Must be between 0 and 1,000g."
        case .invalidCarbs(let value):
            return "Invalid carbohydrates: \(value)g. Must be between 0 and 2,000g."
        case .invalidFat(let value):
            return "Invalid fat: \(value)g. Must be between 0 and 500g."
        case .invalidServingSize(let value):
            return "Invalid serving size: \(value)g. Must be between 0 and 10,000g."
        case .invalidSodium(let value):
            return "Invalid sodium: \(value)mg. Must be between 0 and 50,000mg."
        case .invalidPotassium(let value):
            return "Invalid potassium: \(value)mg. Must be between 0 and 10,000mg."
        case .invalidCholesterol(let value):
            return "Invalid cholesterol: \(value)mg. Must be between 0 and 5,000mg."
        case .invalidFiber(let value):
            return "Invalid fiber: \(value)g. Must be between 0 and 500g."
        case .invalidSugar(let value):
            return "Invalid sugar: \(value)g. Must be between 0 and 1,000g."
        case .invalidName(let name):
            return "Invalid food name: '\(name)'. Must be between 1 and 100 characters."
        case .emptySearchQuery:
            return "Search query cannot be empty."
        case .searchQueryTooShort(let query):
            return "Search query '\(query)' is too short. Must be at least 2 characters."
        case .searchQueryTooLong(let query):
            return "Search query is too long. Must be less than 200 characters."
        }
    }
}

// MARK: - Validation Rules
struct NutritionValidationRules {
    static let caloriesRange = 0.0...10_000.0
    static let proteinRange = 0.0...1_000.0
    static let carbsRange = 0.0...2_000.0
    static let fatRange = 0.0...500.0
    static let servingSizeRange = 0.0...10_000.0
    static let sodiumRange = 0...50_000
    static let potassiumRange = 0...10_000
    static let cholesterolRange = 0...5_000
    static let fiberRange = 0.0...500.0
    static let sugarRange = 0.0...1_000.0
    static let nameLengthRange = 1...100
    static let searchQueryMinLength = 2
    static let searchQueryMaxLength = 200
}

// MARK: - Validation Extensions
extension Item {
    /// Validates nutrition data from API
    func validate() -> [ValidationError] {
        var errors: [ValidationError] = []
        
        // Validate calories
        if let calories = calories, !NutritionValidationRules.caloriesRange.contains(calories) {
            errors.append(.invalidCalories(calories))
        }
        
        // Validate protein
        if let protein = proteinG, !NutritionValidationRules.proteinRange.contains(protein) {
            errors.append(.invalidProtein(protein))
        }
        
        // Validate carbs
        if let carbs = carbohydratesTotalG, !NutritionValidationRules.carbsRange.contains(carbs) {
            errors.append(.invalidCarbs(carbs))
        }
        
        // Validate fat
        if let fat = fatTotalG, !NutritionValidationRules.fatRange.contains(fat) {
            errors.append(.invalidFat(fat))
        }
        
        // Validate serving size
        if let servingSize = servingSizeG, !NutritionValidationRules.servingSizeRange.contains(servingSize) {
            errors.append(.invalidServingSize(servingSize))
        }
        
        // Validate sodium
        if let sodium = sodiumMg, !NutritionValidationRules.sodiumRange.contains(sodium) {
            errors.append(.invalidSodium(sodium))
        }
        
        // Validate potassium
        if let potassium = potassiumMg, !NutritionValidationRules.potassiumRange.contains(potassium) {
            errors.append(.invalidPotassium(potassium))
        }
        
        // Validate cholesterol
        if let cholesterol = cholesterolMg, !NutritionValidationRules.cholesterolRange.contains(cholesterol) {
            errors.append(.invalidCholesterol(cholesterol))
        }
        
        // Validate fiber
        if let fiber = fiberG, !NutritionValidationRules.fiberRange.contains(fiber) {
            errors.append(.invalidFiber(fiber))
        }
        
        // Validate sugar
        if let sugar = sugarG, !NutritionValidationRules.sugarRange.contains(sugar) {
            errors.append(.invalidSugar(sugar))
        }
        
        // Validate name
        if let name = name {
            if !NutritionValidationRules.nameLengthRange.contains(name.count) {
                errors.append(.invalidName(name))
            }
        }
        
        return errors
    }
    
    /// Sanitizes nutrition data by clamping values to valid ranges
    func sanitized() -> Item {
        return Item(
            name: name?.trimmingCharacters(in: .whitespacesAndNewlines),
            calories: calories?.clamped(to: NutritionValidationRules.caloriesRange),
            servingSizeG: servingSizeG?.clamped(to: NutritionValidationRules.servingSizeRange),
            fatTotalG: fatTotalG?.clamped(to: NutritionValidationRules.fatRange),
            fatSaturatedG: fatSaturatedG?.clamped(to: NutritionValidationRules.fatRange),
            proteinG: proteinG?.clamped(to: NutritionValidationRules.proteinRange),
            sodiumMg: sodiumMg?.clamped(to: NutritionValidationRules.sodiumRange),
            potassiumMg: potassiumMg?.clamped(to: NutritionValidationRules.potassiumRange),
            cholesterolMg: cholesterolMg?.clamped(to: NutritionValidationRules.cholesterolRange),
            carbohydratesTotalG: carbohydratesTotalG?.clamped(to: NutritionValidationRules.carbsRange),
            fiberG: fiberG?.clamped(to: NutritionValidationRules.fiberRange),
            sugarG: sugarG?.clamped(to: NutritionValidationRules.sugarRange)
        )
    }
}

extension String {
    /// Validates search query
    func validateSearchQuery() -> [ValidationError] {
        var errors: [ValidationError] = []
        
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            errors.append(.emptySearchQuery)
        } else if trimmed.count < NutritionValidationRules.searchQueryMinLength {
            errors.append(.searchQueryTooShort(trimmed))
        } else if trimmed.count > NutritionValidationRules.searchQueryMaxLength {
            errors.append(.searchQueryTooLong(trimmed))
        }
        
        return errors
    }
    
    /// Sanitizes search query
    func sanitizedSearchQuery() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}

// MARK: - Helper Extensions
extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        if self < range.lowerBound {
            return range.lowerBound
        } else if self > range.upperBound {
            return range.upperBound
        } else {
            return self
        }
    }
} 
