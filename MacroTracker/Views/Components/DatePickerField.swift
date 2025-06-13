import SwiftUI

struct DatePickerField: View {
    let title: String
    @Binding var date: Date
    var displayedComponents: DatePickerComponents = [.date]
    
    var body: some View {
        DatePicker(selection: $date, displayedComponents: displayedComponents) {
            Text(title)
        }
        .datePickerStyle(.compact)
        .tint(.mealsDetailScreenSecondaryTitleColor)
        .frame(height: 56)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.containerBackgroundColor)
        )
        .foregroundColor(Color.mealsDetailScreenSecondaryTitleColor)
        .padding(.horizontal)
        .font(.primaryTitle)
    }
}

#Preview {
    VStack(spacing: 20) {
        DatePickerField(
            title: "Pick your meal date",
            date: .constant(Date())
        )
        
        DatePickerField(
            title: "Select time",
            date: .constant(Date()),
            displayedComponents: [.hourAndMinute]
        )
    }
    .padding()
} 