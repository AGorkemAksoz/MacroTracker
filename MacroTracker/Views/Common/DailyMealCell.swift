import SwiftUI

struct DailyMealCell: View {
    let date: Date
    let meals: [FoodItem]
    
    var totalCalories: Double {
        meals.reduce(0) { $0 + $1.calories }
    }
    
    var totalProtein: Double {
        meals.reduce(0, {$0 + $1.proteinG})
    }
    
    var totalCarbs: Double {
        meals.reduce(0, {$0 + $1.carbohydratesTotalG})
    }
    
    var totalFat: Double {
        meals.reduce(0, {$0 + $1.fatTotalG})
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"  // Shows like "Mon, Jun 5"
        return formatter.string(from: date)
    }
    
    var body: some View {
        IconCell(
            iconName: "dailyCellIcon",
            title: formattedDate,
            subtitle: "\(Int(totalCalories)) kcal | P: \(Int(totalProtein))g, C: \(Int(totalCarbs))g, F: \(Int(totalFat))g"
        )
    }
}

#Preview {
    DailyMealCell(
        date: Date(),
        meals: [
            FoodItem(name: "Oatmeal", calories: 300, proteinG: 10, carbohydratesTotalG: 30, fatTotalG: 5),
            FoodItem(name: "Banana", calories: 100, proteinG: 1, carbohydratesTotalG: 27, fatTotalG: 0)
        ]
    )
    .padding()
} 