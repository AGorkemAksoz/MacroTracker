//
//  PieChartView.swift
//  MacroTracker
//
//  Created by Gorkem on 14.05.2025.
//

import Charts
import SwiftUI

struct Macro: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
    let color: Color
}

struct PieChartView: View {
    var macros: [Macro]
    
    var body: some View {
        Chart(macros, id: \.name) { macro in
            SectorMark(
                angle: .value("Value", macro.value),
                innerRadius: .ratio(0.5),
                angularInset: 1.5
            )
            .foregroundStyle(macro.color)
            .annotation(position: .overlay) {
                VStack {
                    Text(macro.name)
                        .font(.system(size: 14).bold())
                        .foregroundColor(.white)
                    
                    Text("\(macro.value.formatted(.number))")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
            }
        }
        .frame(height: 300)
        .padding()
    }
}
