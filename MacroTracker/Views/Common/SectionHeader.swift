import SwiftUI

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.dayDetailTitle)
                .padding()
            Spacer()
        }
    }
}

#Preview {
    VStack {
        SectionHeader(title: "Meals")
        SectionHeader(title: "Nutrition")
        SectionHeader(title: "Daily Summary")
    }
} 