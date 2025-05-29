import SwiftUI

struct FoodDetailView: View {
    let foodItem: FoodItem
    @Environment(\.dismiss) private var dismiss
    
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
            Text(foodItem.name)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(foodItem.mealType.mealName)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(foodItem.recordedDate.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var macroSummarySection: some View {
        VStack(spacing: 16) {
            Text("Macro Summary")
                .font(.headline)
            
            HStack(spacing: 20) {
                MacroCircleView(
                    title: "Protein",
                    value: foodItem.proteinG,
                    unit: "g",
                    color: .blue
                )
                
                MacroCircleView(
                    title: "Carbs",
                    value: foodItem.carbohydratesTotalG,
                    unit: "g",
                    color: .green
                )
                
                MacroCircleView(
                    title: "Fat",
                    value: foodItem.fatTotalG,
                    unit: "g",
                    color: .orange
                )
            }
            
            Text("\(Int(foodItem.calories)) calories")
                .font(.title2)
                .fontWeight(.semibold)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
    
    private var nutritionDetailsSection: some View {
        VStack(spacing: 16) {
            Text("Detailed Nutrition")
                .font(.headline)
            
            VStack(spacing: 12) {
                NutritionRowView(
                    title: "Total Fat",
                    value: foodItem.fatTotalG,
                    unit: "g"
                )
                
                NutritionRowView(
                    title: "Saturated Fat",
                    value: foodItem.fatSaturatedG,
                    unit: "g",
                    indent: true
                )
                
                NutritionRowView(
                    title: "Total Carbohydrates",
                    value: foodItem.carbohydratesTotalG,
                    unit: "g"
                )
                
                NutritionRowView(
                    title: "Fiber",
                    value: foodItem.fiberG,
                    unit: "g",
                    indent: true
                )
                
                NutritionRowView(
                    title: "Sugar",
                    value: foodItem.sugarG,
                    unit: "g",
                    indent: true
                )
                
                NutritionRowView(
                    title: "Protein",
                    value: foodItem.proteinG,
                    unit: "g"
                )
                
                NutritionRowView(
                    title: "Cholesterol",
                    value: Double(foodItem.cholesterolMg),
                    unit: "mg"
                )
                
                NutritionRowView(
                    title: "Sodium",
                    value: Double(foodItem.sodiumMg),
                    unit: "mg"
                )
                
                NutritionRowView(
                    title: "Potassium",
                    value: Double(foodItem.potassiumMg),
                    unit: "mg"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
    
    private var servingSection: some View {
        VStack(spacing: 8) {
            Text("Serving Information")
                .font(.headline)
            
            Text("Serving Size: \(Int(foodItem.servingSizeG))g")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
}

// MARK: - Supporting Views

struct MacroCircleView: View {
    let title: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: min(value / 100, 1))
                    .stroke(color,
                            style: StrokeStyle(lineWidth: 8,
                                               lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text(String(format: "%.1f", value))
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                    Text(unit)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct NutritionRowView: View {
    let title: String
    let value: Double
    let unit: String
    var indent: Bool = false
    
    var body: some View {
        HStack {
            if indent {
                Text("• ")
                    .foregroundColor(.secondary)
            }
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(String(format: "%.1f", value))\(unit)")
                .foregroundColor(.secondary)
        }
        .padding(.leading, indent ? 16 : 0)
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
