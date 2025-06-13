import SwiftUI

struct SearchBar: View {
    let placeholder: String
    @Binding var text: String
    var isLoading: Bool = false
    var onTextChange: ((String) -> Void)? = nil
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .font(.primaryTitle)
            .foregroundStyle(Color.mealsDetailScreenSecondaryTitleColor)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.containerBackgroundColor)
            )
            .frame(height: 56)
            .padding(.horizontal)
            .overlay {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .onChange(of: text) { oldValue, newValue in
                onTextChange?(newValue)
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        SearchBar(
            placeholder: "Type Your Meal",
            text: .constant(""),
            isLoading: false
        )
        
        SearchBar(
            placeholder: "Search...",
            text: .constant("Chicken"),
            isLoading: true
        )
    }
    .padding()
} 