//
//  WeeklySummaryView.swift
//  MacroTracker
//
//  Created by Ali Görkem Aksöz on 29.05.2025.
//

import Charts
import SwiftUI

struct WeeklySummaryView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @StateObject private var viewModel: WeeklySummaryViewModel
    
    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        self._viewModel = StateObject(wrappedValue: WeeklySummaryViewModel(homeViewModel: homeViewModel))
    }
    
    var body: some View {
        VStack {
            if viewModel.chartData.isEmpty {
                Text("No data available for the past week")
                    .foregroundColor(.secondary)
            } else {
                Chart(viewModel.chartData, id: \.id) { item in
                    BarMark(
                        x: .value("Day", item.dayName),
                        y: .value("Calories", item.consumedCalories)
                    )
                    .foregroundStyle(Color.blue.gradient)
                }
                .frame(height: 200)
                .padding()
                
                // Weekly totals
                VStack(spacing: 12) {
                    MacroSummaryRow(title: "Total Calories", value: viewModel.totalWeeklyCalories, unit: "kcal")
                    MacroSummaryRow(title: "Avg. Daily Protein", value: viewModel.averageProtein, unit: "g")
                    MacroSummaryRow(title: "Avg. Daily Carbs", value: viewModel.averageCarbs, unit: "g")
                    MacroSummaryRow(title: "Avg. Daily Fat", value: viewModel.averageFat, unit: "g")
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.updateChartData()
        }
    }
}

struct MacroSummaryRow: View {
    let title: String
    let value: Double
    let unit: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(String(format: "%.1f %@", value, unit))
                .fontWeight(.medium)
        }
    }
}
