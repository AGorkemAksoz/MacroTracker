import SwiftUI

struct MacroInfoView: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    HStack {
        MacroInfoView(label: "Cal", value: "500")
        MacroInfoView(label: "P", value: "30g")
        MacroInfoView(label: "C", value: "50g")
        MacroInfoView(label: "F", value: "20g")
    }
    .padding()
} 
