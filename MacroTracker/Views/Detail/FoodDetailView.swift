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
                macroSummarySection
                
                // Detailed Nutrition
                nutritionDetailsSection
                
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
    
    private var macroSummarySection: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Calories")
                        .font(.secondaryNumberTitle)
                    
                    Text(data.calories.formatted(.number))
                        .font(.dayDetailTitle)
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        .frame(height: UIScreen.main.bounds.height / 8)
        .frame(maxWidth: .infinity)
        .background(Color.containerBackgroundColor)
        .cornerRadius(8)
    }
    
    private var nutritionDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Macros")
                .font(.dayDetailTitle)
                .padding(.top)
            
            HStack {
                Text("Protein")
                    .foregroundStyle(Color.mealsDetailScreenSecondaryTitleColor)
                Spacer()
                Text("\(data.proteinG.formatted(.number)) gr")
            }
            .font(.secondaryNumberTitle)
            
            HStack {
                Text("Carbs")
                    .foregroundStyle(Color.mealsDetailScreenSecondaryTitleColor)
                Spacer()
                Text("\(data.carbohydratesTotalG.formatted(.number)) gr")
            }
            .font(.secondaryNumberTitle)
            
            HStack {
                Text("Fats")
                    .foregroundStyle(Color.mealsDetailScreenSecondaryTitleColor)
                Spacer()
                Text("\(data.fatTotalG.formatted(.number)) gr")
            }
            .font(.secondaryNumberTitle)
            
            Text("Micronutrients")
                .font(.dayDetailTitle)
                .padding(.top)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                NutrientGridItem(title: "Fiber", value: data.fiberG, unit: "g")
                NutrientGridItem(title: "Sugar", value: data.sugarG, unit: "g")
                NutrientGridItem(title: "Cholesterol", value: Double(data.cholesterolMg), unit: "mg")
                NutrientGridItem(title: "Sodium", value: Double(data.sodiumMg), unit: "mg")
                NutrientGridItem(title: "Potassium", value: Double(data.potassiumMg), unit: "mg")
                NutrientGridItem(title: "Protein", value: data.proteinG, unit: "g")
                NutrientGridItem(title: "Carbs", value: data.carbohydratesTotalG, unit: "g")
                NutrientGridItem(title: "Fat Saturated", value: data.fatSaturatedG, unit: "g")
            }
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
