import SwiftUI

struct MealTypeCell: View {
    let mealType: MealTypes
    let meals: [FoodItem]
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(mealType.iconName)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.appForegroundColor)
                .padding(12)
                .background(Color.containerBackgroundColor)
                .cornerRadius(8)
                .padding(.leading)
            
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
    }
}

#Preview {
    MealTypeCell(
        mealType: .breakfeast,
        meals: [
            FoodItem(name: "Oatmeal", fatTotalG: 5, proteinG: 10, carbohydratesTotalG: 30),
            FoodItem(name: "Banana", fatTotalG: 0, proteinG: 1, carbohydratesTotalG: 27)
        ]
    )
    .padding()
} 
