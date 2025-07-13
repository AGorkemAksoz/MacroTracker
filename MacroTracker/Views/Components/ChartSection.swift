//
//  ChartSection.swift
//  MacroTracker
//
//  Created by Gorkem on 19.05.2025.
//

import SwiftUI

struct ChartSection<Chart: View>: View {
    let title: String
    let value: String
    let change: Int
    let comparisonLabel: String
    let chart: Chart
    let chartHeight: CGFloat
    
    init(
        title: String,
        value: String,
        change: Int,
        comparisonLabel: String,
        chartHeight: CGFloat = 100,
        @ViewBuilder chart: () -> Chart
    ) {
        self.title = title
        self.value = value
        self.change = change
        self.comparisonLabel = comparisonLabel
        self.chartHeight = chartHeight
        self.chart = chart()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ProgressNutritionCard(
                title: title,
                value: value,
                change: change,
                comparisonLabel: comparisonLabel
            )
            
            chart
                .frame(height: chartHeight)
                .padding(.horizontal)
        }
    }
}

// MARK: - Convenience Initializers

extension ChartSection {
    init(
        title: String,
        value: Int,
        unit: String = "",
        change: Int,
        comparisonLabel: String,
        chartHeight: CGFloat = 100,
        @ViewBuilder chart: () -> Chart
    ) {
        let formattedValue = unit.isEmpty ? "\(value)" : "\(value)\(unit)"
        self.init(
            title: title,
            value: formattedValue,
            change: change,
            comparisonLabel: comparisonLabel,
            chartHeight: chartHeight,
            chart: chart
        )
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 32) {
            ChartSection(
                title: "Calories",
                value: 2150,
                change: 12,
                comparisonLabel: "vs Last 7 Days",
                chartHeight: 120
            ) {
                Rectangle()
                    .fill(Color.blue.opacity(0.3))
                    .overlay(
                        Text("Line Chart")
                            .foregroundColor(.blue)
                    )
            }
            
            ChartSection(
                title: "Protein",
                value: 125,
                unit: "g",
                change: -5,
                comparisonLabel: "vs Last 7 Days"
            ) {
                Rectangle()
                    .fill(Color.green.opacity(0.3))
                    .overlay(
                        Text("Bar Chart")
                            .foregroundColor(.green)
                    )
            }
            
            ChartSection(
                title: "Fat",
                value: 80,
                unit: "g",
                change: 0,
                comparisonLabel: "vs Last Month"
            ) {
                Rectangle()
                    .fill(Color.orange.opacity(0.3))
                    .overlay(
                        Text("Bar Chart")
                            .foregroundColor(.orange)
                    )
            }
        }
        .padding()
    }
} 