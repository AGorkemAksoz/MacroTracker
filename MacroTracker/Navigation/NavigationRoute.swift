//
//  NavigationRoute.swift
//  MacroTracker
//
//  Created by Gorkem on 24.02.2025.
//

import SwiftUI
import SwiftData

enum AppRoute: Hashable {
    case home
    case enterFood
    case confirmFood(foods: [Item], date: Date, mealType: MealTypes)
    case dailyMealDetail(date: Date)
    case mealTypeDetail(type: MealTypes, meals: [FoodItem], date: Date)  // Added date parameter
    case foodDetail(food: FoodItem)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .home:
            hasher.combine(0)
        case .enterFood:
            hasher.combine(1)
        case .confirmFood(let foods, let date, let mealType):
            hasher.combine(2)
            hasher.combine(foods.map { $0.name })
            hasher.combine(date)
            hasher.combine(mealType)
        case .dailyMealDetail(let date):
            hasher.combine(3)
            hasher.combine(date)
        case .mealTypeDetail(let type, let meals, let date):  // Updated
            hasher.combine(4)
            hasher.combine(type)
            hasher.combine(meals.map { $0.id })
            hasher.combine(date)
        case .foodDetail(let food):
            hasher.combine(5)
            hasher.combine(food.id)
        }
    }
    
    static func == (lhs: AppRoute, rhs: AppRoute) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home):
            return true
        case (.enterFood, .enterFood):
            return true
        case (.confirmFood(let foods1, let date1, let meal1),
              .confirmFood(let foods2, let date2, let meal2)):
            return foods1.map({ $0.name }) == foods2.map({ $0.name }) &&
                   date1 == date2 &&
                   meal1 == meal2
        case (.dailyMealDetail(let date1), .dailyMealDetail(let date2)):
            return date1 == date2
        case (.mealTypeDetail(let type1, let meals1, let date1),  // Updated
              .mealTypeDetail(let type2, let meals2, let date2)):
            return type1 == type2 &&
                   meals1.map({ $0.id }) == meals2.map({ $0.id }) &&
                   date1 == date2
        case (.foodDetail(let food1), .foodDetail(let food2)):
            return food1.id == food2.id
        default:
            return false
        }
    }
} 