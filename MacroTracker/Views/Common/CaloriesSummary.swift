import SwiftUI

struct CaloriesSummary: View {
    let calories: Double
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Calories")
                        .font(.secondaryNumberTitle)
                    
                    Text(calories.formatted(.number))
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
}

#Preview {
    CaloriesSummary(calories: 500)
        .padding()
} 