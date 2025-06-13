import SwiftUI

struct IconCell: View {
    let iconName: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            Image(iconName)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.appForegroundColor)
                .padding(12)
                .background(Color.containerBackgroundColor)
                .cornerRadius(8)
                .padding(.leading)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.primaryTitle)
                    .foregroundStyle(Color.appForegroundColor)
                
                Text(subtitle)
                    .font(.secondaryNumberTitle)
                    .foregroundStyle(Color.mealsDetailScreenSecondaryTitleColor)
            }
            Spacer()
        }
    }
}

#Preview {
    VStack {
        IconCell(
            iconName: "breakfastIcon",
            title: "Breakfast",
            subtitle: "500 kcal"
        )
        IconCell(
            iconName: "dinnerIcon",
            title: "Dinner",
            subtitle: "800 kcal"
        )
    }
    .padding()
} 