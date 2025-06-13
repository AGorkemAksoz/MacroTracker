import SwiftUI

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headerTitle)
                .foregroundStyle(Color.appForegroundColor)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SectionHeader(title: "Today's Macros")
    }
    .padding()
} 
