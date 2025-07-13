//
//  BarAnnotationCard.swift
//  MacroTracker
//
//  Created by Gorkem on 21.05.2025.
//

import SwiftUI

struct BarAnnotationCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.secondaryNumberTitle)
                .foregroundStyle(Color.secondayNumberForegroundColor)
            Text(value)
                .font(.primaryNumberTitle)
                .foregroundStyle(Color.appForegroundColor)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.containerBackgroundColor)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        BarAnnotationCard(
            title: "Mon, Dec 9",
            value: "125g"
        )
        
        BarAnnotationCard(
            title: "Today",
            value: "2,150"
        )
        
        BarAnnotationCard(
            title: "Wed",
            value: "80g"
        )
    }
    .padding()
} 