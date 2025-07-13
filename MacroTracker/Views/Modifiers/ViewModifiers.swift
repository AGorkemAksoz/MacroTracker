//
//  ViewModifiers.swift
//  MacroTracker
//
//  Created by Gorkem on 5.06.2025.
//

import SwiftUI

// MARK: - Card Style
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.containerBackgroundColor)
            )
    }
}

// MARK: - Section Style
struct SectionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headerTitle)
            .foregroundStyle(Color.appForegroundColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .top])
    }
}

// MARK: - Icon Container Style
struct IconContainerStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 24, height: 24)
            .foregroundStyle(Color.appForegroundColor)
            .padding(12)
            .background(Color.containerBackgroundColor)
            .cornerRadius(8)
            .padding(.leading)
    }
}

// MARK: - Nutrient Value Style
struct NutrientValueStyle: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .font(.secondaryNumberTitle)
            .foregroundStyle(color)
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func sectionStyle() -> some View {
        modifier(SectionStyle())
    }
    
    func iconContainerStyle() -> some View {
        modifier(IconContainerStyle())
    }
    
    func nutrientValueStyle(color: Color) -> some View {
        modifier(NutrientValueStyle(color: color))
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        Text("Card Style")
            .cardStyle()
        
        Text("Section Style")
            .sectionStyle()
        
        Image(systemName: "star")
            .iconContainerStyle()
        
        Text("100g")
            .nutrientValueStyle(color: .appForegroundColor)
    }
    .padding()
} 
