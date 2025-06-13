import SwiftUI

struct MealTypeCell: View {
    let mealType: MealTypes
    let meals: [FoodItem]
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(mealType.iconName)
                .resizable()
                .iconContainerStyle()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mealType.mealName)
                    .font(.primaryTitle)
                    .foregroundStyle(Color.appForegroundColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(meals) { meal in
                        Text("\(meal.name): P: \(Int(meal.proteinG))g, C: \(Int(meal.carbohydratesTotalG))g, F: \(Int(meal.fatTotalG))g")
                    }
                    Text("Total: P: \(Int(meals.totalProtein))g, C: \(Int(meals.totalCarbs))g, F: \(Int(meals.totalFat))g")
                        .fontWeight(.medium)
                }
                .font(.secondaryNumberTitle)
                .foregroundStyle(Color.secondayNumberForegroundColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    MealTypeCell(
        mealType: .breakfeast,
        meals: [
            FoodItem(
                name: "Chicken Breast",
                calories: 250,
                fatTotalG: 5, proteinG: 30,
                carbohydratesTotalG: 0
            ),
            FoodItem(
                name: "Rice",
                calories: 200,
                fatTotalG: 0, proteinG: 4,
                carbohydratesTotalG: 45
            )
        ]
    )
    .padding()
} 
