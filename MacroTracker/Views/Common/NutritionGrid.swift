import SwiftUI

struct NutritionGrid: View {
    let items: [NutritionGridItem]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(items) { item in
                NutrientGridItem(title: item.title, value: item.value, unit: item.unit)
            }
        }
        .padding()
    }
}

struct NutritionGridItem: Identifiable {
    let id = UUID()
    let title: String
    let value: Double
    let unit: String
}

#Preview {
    NutritionGrid(items: [
        NutritionGridItem(title: "Fiber", value: 5.0, unit: "g"),
        NutritionGridItem(title: "Sugar", value: 10.0, unit: "g"),
        NutritionGridItem(title: "Protein", value: 20.0, unit: "g"),
        NutritionGridItem(title: "Carbs", value: 30.0, unit: "g")
    ])
} 