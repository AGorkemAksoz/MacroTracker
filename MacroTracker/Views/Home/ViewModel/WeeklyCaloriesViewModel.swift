//
//  WeeklyCalories.swift
//  MacroTracker
//
//  Created by Ali Görkem Aksöz on 29.05.2025.
//

import Foundation

struct WeeklyCalories: Identifiable {
    let id = UUID()
    let date: Date
    let consumedCalories: Double
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}


class WeeklySummaryViewModel: ObservableObject {
    @Published var chartData: [WeeklyCalories] = []
    @Published var totalWeeklyCalories: Double = 0
    @Published var averageProtein: Double = 0
    @Published var averageCarbs: Double = 0
    @Published var averageFat: Double = 0
    
    private let homeViewModel: HomeViewModel
    
    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
    }
    
    func updateChartData() {
        let calendar = Calendar.current
        let today = Date()
        
        // Get the date 7 days ago
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: today)) else {
            return
        }
        
        // Get all food items
        let allFoodItems = homeViewModel.savedNutrititon
        
        // Create a dictionary to store daily totals
        var dailyData: [Date: WeeklyCalories] = [:]
        var totalProtein: Double = 0
        var totalCarbs: Double = 0
        var totalFat: Double = 0
        var daysWithData = 0
        
        // Initialize all days in the range
        for dayOffset in 0...6 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: sevenDaysAgo) {
                dailyData[calendar.startOfDay(for: date)] = WeeklyCalories(
                    date: date,
                    consumedCalories: 0
                )
            }
        }
        
        // Aggregate the data
        for item in allFoodItems {
            let itemDate = calendar.startOfDay(for: item.recordedDate)
            if itemDate >= sevenDaysAgo && itemDate <= today {
                if let existingData = dailyData[itemDate] {
                    dailyData[itemDate] = WeeklyCalories(
                        date: existingData.date,
                        consumedCalories: existingData.consumedCalories + item.calories
                    )
                }
                
                // Accumulate macro totals
                totalProtein += item.proteinG
                totalCarbs += item.carbohydratesTotalG
                totalFat += item.fatTotalG
                daysWithData += 1
            }
        }
        
        // Sort the data by date
        chartData = dailyData.values.sorted { $0.date < $1.date }
        
        // Calculate totals and averages
        totalWeeklyCalories = chartData.reduce(0) { $0 + $1.consumedCalories }
        
        // Calculate averages (prevent division by zero)
        let divisor = max(Double(daysWithData), 1)
        averageProtein = totalProtein / divisor
        averageCarbs = totalCarbs / divisor
        averageFat = totalFat / divisor
    }
}
