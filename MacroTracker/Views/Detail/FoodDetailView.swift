import SwiftUI

struct FoodDetailView: View {
    let data: FoodDetailDataProvider
    @Environment(\.dismiss) private var dismiss
    
    init(data: FoodDetailDataProvider) {
        self.data = data
    }
    
    // Convenience initializer for FoodItem
    init(foodItem: FoodItem) {
        self.init(data: foodItem)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Macro Summary
                CaloriesSummary(calories: data.calories)
                
                // Detailed Nutrition
                MacroSummary(
                    protein: data.proteinG,
                    carbs: data.carbohydratesTotalG,
                    fat: data.fatTotalG
                )
                
                SectionHeader(title: "Micronutrients")
                
                NutritionGrid(items: [
                    NutritionGridItem(title: "Fiber", value: data.fiberG, unit: "g"),
                    NutritionGridItem(title: "Sugar", value: data.sugarG, unit: "g"),
                    NutritionGridItem(title: "Cholesterol", value: Double(data.cholesterolMg), unit: "mg"),
                    NutritionGridItem(title: "Sodium", value: Double(data.sodiumMg), unit: "mg"),
                    NutritionGridItem(title: "Potassium", value: Double(data.potassiumMg), unit: "mg"),
                    NutritionGridItem(title: "Protein", value: data.proteinG, unit: "g"),
                    NutritionGridItem(title: "Carbs", value: data.carbohydratesTotalG, unit: "g"),
                    NutritionGridItem(title: "Fat Saturated", value: data.fatSaturatedG, unit: "g")
                ])
                
                // Serving Information
                servingSection
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(data.name)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(data.mealType.mealName)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(data.recordedDate.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var servingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Serving Size")
                .font(.dayDetailTitle)
            
            Text("\(data.servingSizeG.formatted(.number)) grams")
                .font(.secondaryNumberTitle)
                .foregroundStyle(Color.mealsDetailScreenSecondaryTitleColor)
        }
    }
}

#Preview {
    NavigationView {
        FoodDetailView(foodItem: FoodItem(
            name: "Chicken Breast",
            calories: 165,
            servingSizeG: 100,
            fatTotalG: 3.6,
            fatSaturatedG: 1.1,
            proteinG: 31,
            sodiumMg: 74,
            potassiumMg: 256,
            cholesterolMg: 85,
            carbohydratesTotalG: 0,
            fiberG: 0,
            sugarG: 0
        ))
    }
} 
