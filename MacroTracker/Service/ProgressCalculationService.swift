//
//  ProgressCalculationService.swift
//  MacroTracker
//
//  Created by Gorkem on 14.07.2025.
//

import Foundation

/// Protocol for progress calculations with error handling
protocol ProgressCalculationService {
    /// Calculates progress data for the specified tab with error handling
    func calculateProgress(for tab: ProgressViewModel.Tab, nutrition: [FoodItem]) throws -> ProgressCalculationResult
}

/// Concrete implementation of progress calculations with error handling
class ConcreteProgressCalculationService: ProgressCalculationService {
    
    // MARK: - Static Date Formatters
    private static let weekDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()
    
    // MARK: - Public Interface
    
    func calculateProgress(for tab: ProgressViewModel.Tab, nutrition: [FoodItem]) throws -> ProgressCalculationResult {
        // Validate input data
        guard !nutrition.isEmpty else {
            throw ProgressError.noData
        }
        
        // Check for corrupted data
        guard nutrition.allSatisfy({ $0.calories >= 0 && $0.proteinG >= 0 && $0.fatTotalG >= 0 }) else {
            throw ProgressError.dataCorrupted
        }
        
        do {
            switch tab {
            case .weekly:
                return try calculateWeeklyProgress(nutrition: nutrition)
            case .monthly:
                return try calculateMonthlyProgress(nutrition: nutrition)
            }
        } catch let error as ProgressError {
            throw error
        } catch {
            throw ProgressError.unknown(error)
        }
    }
    
    // MARK: - Weekly Progress Calculation
    
    private func calculateWeeklyProgress(nutrition: [FoodItem]) throws -> ProgressCalculationResult {
        let calendar = Calendar.current
        let currentWeek = (0..<7).map { calendar.date(byAdding: .day, value: -$0, to: Date())! }.reversed()
        let previousWeek = (7..<14).map { calendar.date(byAdding: .day, value: -$0, to: Date())! }.reversed()
        
        // Calculate data arrays
        let caloriesData = currentWeek.map { total(for: $0, keyPath: \.calories, nutrition: nutrition) }
        let proteinData = currentWeek.map { total(for: $0, keyPath: \.proteinG, nutrition: nutrition) }
        let fatData = currentWeek.map { total(for: $0, keyPath: \.fatTotalG, nutrition: nutrition) }
        
        let prevCalories = previousWeek.map { total(for: $0, keyPath: \.calories, nutrition: nutrition) }
        let prevProtein = previousWeek.map { total(for: $0, keyPath: \.proteinG, nutrition: nutrition) }
        let prevFat = previousWeek.map { total(for: $0, keyPath: \.fatTotalG, nutrition: nutrition) }
        
        // Check for insufficient data
        let hasCurrentWeekData = caloriesData.contains { $0 > 0 }
        guard hasCurrentWeekData else {
            throw ProgressError.insufficientData
        }
        
        // Format day labels
        let days = currentWeek.map { Self.weekDayFormatter.string(from: $0) }
        
        // Create chart data
        let chartData = ChartData(
            caloriesData: caloriesData,
            proteinData: proteinData,
            fatData: fatData,
            days: days
        )
        
        // Create nutrition data
        let nutritionData = NutritionData(
            calories: Int(caloriesData.last ?? 0),
            protein: Int(proteinData.last ?? 0),
            fat: Int(fatData.last ?? 0),
            caloriesChange: percentChange(current: caloriesData, previous: prevCalories),
            proteinChange: percentChange(current: proteinData, previous: prevProtein),
            fatChange: percentChange(current: fatData, previous: prevFat),
            comparisonLabel: "vs Last 7 Days"
        )
        
        return ProgressCalculationResult(nutritionData: nutritionData, chartData: chartData)
    }
    
    // MARK: - Monthly Progress Calculation
    
    private func calculateMonthlyProgress(nutrition: [FoodItem]) throws -> ProgressCalculationResult {
        let monthly = try aggregateMonthly(meals: nutrition)
        
        guard !monthly.isEmpty else {
            throw ProgressError.insufficientData
        }
        
        let chartData = ChartData(
            caloriesData: monthly.map { $0.calories },
            proteinData: monthly.map { $0.protein },
            fatData: monthly.map { $0.fat },
            days: monthly.map { Self.monthFormatter.string(from: $0.date) }
        )
        
        let nutritionData: NutritionData
        if monthly.count >= 2 {
            nutritionData = NutritionData(
                calories: Int(monthly.last?.calories ?? 0),
                protein: Int(monthly.last?.protein ?? 0),
                fat: Int(monthly.last?.fat ?? 0),
                caloriesChange: percentChange(
                    current: [monthly.last!.calories],
                    previous: [monthly[monthly.count-2].calories]
                ),
                proteinChange: percentChange(
                    current: [monthly.last!.protein],
                    previous: [monthly[monthly.count-2].protein]
                ),
                fatChange: percentChange(
                    current: [monthly.last!.fat],
                    previous: [monthly[monthly.count-2].fat]
                ),
                comparisonLabel: "vs Last Month"
            )
        } else {
            nutritionData = NutritionData(
                calories: Int(monthly.last?.calories ?? 0),
                protein: Int(monthly.last?.protein ?? 0),
                fat: Int(monthly.last?.fat ?? 0),
                caloriesChange: 0,
                proteinChange: 0,
                fatChange: 0,
                comparisonLabel: "vs Last Month"
            )
        }
        
        return ProgressCalculationResult(nutritionData: nutritionData, chartData: chartData)
    }
    
    // MARK: - Helper Methods
    
    private func total(for date: Date, keyPath: KeyPath<FoodItem, Double>, nutrition: [FoodItem]) -> Double {
        let calendar = Calendar.current
        return nutrition
            .filter { calendar.isDate($0.recordedDate, inSameDayAs: date) }
            .reduce(0) { $0 + $1[keyPath: keyPath] }
    }
    
    private func percentChange(current: [Double], previous: [Double]) -> Int {
        let prevAvg = previous.isEmpty ? 0 : previous.reduce(0, +) / Double(previous.count)
        let currAvg = current.isEmpty ? 0 : current.reduce(0, +) / Double(current.count)
        guard prevAvg != 0 else { return 0 }
        return Int(((currAvg - prevAvg) / prevAvg) * 100)
    }
    
    private func aggregateMonthly(meals: [FoodItem]) throws -> [MonthlyDataPoint] {
        guard !meals.isEmpty else {
            throw ProgressError.noData
        }
        
        let calendar = Calendar.current
        let groupedByMonth = Dictionary(grouping: meals) { item -> Date in
            let components = calendar.dateComponents([.year, .month], from: item.recordedDate)
            return calendar.date(from: components)!
        }
        
        return groupedByMonth.keys.sorted().map { monthDate -> MonthlyDataPoint in
            let items = groupedByMonth[monthDate, default: []]
            let daysWithData = Double(Set(items.map { calendar.startOfDay(for: $0.recordedDate) }).count)
            guard daysWithData > 0 else {
                return MonthlyDataPoint(date: monthDate, calories: 0, protein: 0, fat: 0)
            }
            
            let totalCalories = items.reduce(0) { $0 + $1.calories }
            let totalProtein = items.reduce(0) { $0 + $1.proteinG }
            let totalFat = items.reduce(0) { $0 + $1.fatTotalG }
            
            return MonthlyDataPoint(
                date: monthDate,
                calories: totalCalories / daysWithData,
                protein: totalProtein / daysWithData,
                fat: totalFat / daysWithData
            )
        }
    }
}
