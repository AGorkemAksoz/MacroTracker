import SwiftUI

struct MacroSummary: View {
    let protein: Double
    let carbs: Double
    let fat: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Macros")
                .font(.dayDetailTitle)
                .padding(.top)
            
            HStack {
                Text("Protein")
                    .foregroundStyle(Color.mealsDetailScreenSecondaryTitleColor)
                Spacer()
                Text("\(protein.formatted(.number)) gr")
            }
            .font(.secondaryNumberTitle)
            
            HStack {
                Text("Carbs")
                    .foregroundStyle(Color.mealsDetailScreenSecondaryTitleColor)
                Spacer()
                Text("\(carbs.formatted(.number)) gr")
            }
            .font(.secondaryNumberTitle)
            
            HStack {
                Text("Fats")
                    .foregroundStyle(Color.mealsDetailScreenSecondaryTitleColor)
                Spacer()
                Text("\(fat.formatted(.number)) gr")
            }
            .font(.secondaryNumberTitle)
        }
    }
}

#Preview {
    MacroSummary(protein: 30, carbs: 50, fat: 20)
        .padding()
} 