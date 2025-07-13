//
//  ProgressViewModel.swift
//  MacroTracker
//
//  Created by Gorkem on 16.05.2025.
//

import Foundation
import Combine

// MARK: - Error Types

/// Specific error types for progress view with user-friendly messages
enum ProgressError: Error, LocalizedError {
    case noData
    case insufficientData
    case calculationFailed
    case dataCorrupted
    case networkError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .noData:
            return "No nutrition data available"
        case .insufficientData:
            return "Not enough data to show progress"
        case .calculationFailed:
            return "Unable to calculate progress"
        case .dataCorrupted:
            return "Data appears to be corrupted"
        case .networkError:
            return "Network connection error"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noData:
            return "Start logging your meals to see your progress"
        case .insufficientData:
            return "Log more meals to see detailed progress charts"
        case .calculationFailed:
            return "Please try again or restart the app"
        case .dataCorrupted:
            return "Please restart the app or contact support"
        case .networkError:
            return "Check your internet connection and try again"
        case .unknown:
            return "Please try again or restart the app"
        }
    }
}

// MARK: - Enhanced Loading State

/// Enhanced loading state with detailed states and messages
enum LoadingState {
    case idle
    case loading(message: String)
    case loaded
    case error(ProgressError)
    case empty
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .error(let error) = self {
            return error.errorDescription
        }
        return nil
    }
    
    var recoverySuggestion: String? {
        if case .error(let error) = self {
            return error.recoverySuggestion
        }
        return nil
    }
}

// MARK: - Data Models

/// Represents nutrition summary data with current values and changes
struct NutritionData {
    let calories: Int
    let protein: Int
    let fat: Int
    let caloriesChange: Int
    let proteinChange: Int
    let fatChange: Int
    let comparisonLabel: String
    
    static let empty = NutritionData(
        calories: 0,
        protein: 0,
        fat: 0,
        caloriesChange: 0,
        proteinChange: 0,
        fatChange: 0,
        comparisonLabel: ""
    )
}

/// Represents chart data for visualization
struct ChartData {
    let caloriesData: [Double]
    let proteinData: [Double]
    let fatData: [Double]
    let days: [String]
    
    static let empty = ChartData(
        caloriesData: [],
        proteinData: [],
        fatData: [],
        days: []
    )
    
    /// Checks if the chart data is empty or insufficient
    var isEmpty: Bool {
        return caloriesData.isEmpty && proteinData.isEmpty && fatData.isEmpty
    }
    
    /// Checks if there's sufficient data for meaningful charts
    var hasSufficientData: Bool {
        return caloriesData.count >= 2 && proteinData.count >= 2 && fatData.count >= 2
    }
}

/// Represents the complete progress state with enhanced error handling
struct ProgressState {
    let selectedTab: ProgressViewModel.Tab
    let nutritionData: NutritionData
    let chartData: ChartData
    let loadingState: LoadingState
    
    static let initial = ProgressState(
        selectedTab: .weekly,
        nutritionData: .empty,
        chartData: .empty,
        loadingState: .idle
    )
    
    /// Convenience property for backward compatibility
    var isLoading: Bool {
        return loadingState.isLoading
    }
}

/// Result type for progress calculations
struct ProgressCalculationResult {
    let nutritionData: NutritionData
    let chartData: ChartData
}

/// Data structure for monthly aggregation
struct MonthlyDataPoint {
    let date: Date
    let calories: Double
    let protein: Double
    let fat: Double
}

// MARK: - Helper Extensions

extension ProgressState {
    /// Creates a copy of the current state with updated values
    func copy(
        selectedTab: ProgressViewModel.Tab? = nil,
        nutritionData: NutritionData? = nil,
        chartData: ChartData? = nil,
        loadingState: LoadingState? = nil
    ) -> ProgressState {
        return ProgressState(
            selectedTab: selectedTab ?? self.selectedTab,
            nutritionData: nutritionData ?? self.nutritionData,
            chartData: chartData ?? self.chartData,
            loadingState: loadingState ?? self.loadingState
        )
    }
}

// MARK: - Service Protocols

/// Protocol for accessing progress-related data
protocol ProgressDataService {
    /// Current saved nutrition data
    var savedNutrition: [FoodItem] { get }
    
    /// Publisher for saved nutrition data changes
    var savedNutritionPublisher: AnyPublisher<[FoodItem], Never> { get }
}

/// Protocol for progress calculations with error handling
protocol ProgressCalculationService {
    /// Calculates progress data for the specified tab with error handling
    func calculateProgress(for tab: ProgressViewModel.Tab, nutrition: [FoodItem]) throws -> ProgressCalculationResult
}

// MARK: - Service Implementations

/// Concrete implementation of ProgressDataService using HomeViewModel
class ConcreteProgressDataService: ProgressDataService {
    private let homeViewModel: HomeViewModel
    
    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
    }
    
    var savedNutrition: [FoodItem] {
        homeViewModel.savedNutrititon
    }
    
    var savedNutritionPublisher: AnyPublisher<[FoodItem], Never> {
        homeViewModel.$savedNutrititon.eraseToAnyPublisher()
    }
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
        } catch {
            throw ProgressError.calculationFailed
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

// MARK: - Progress View Model

class ProgressViewModel: ObservableObject {
    enum Tab: Int, CaseIterable { case weekly = 0, monthly = 1 }
    
    // MARK: - State Management
    @Published private(set) var state = ProgressState.initial
    
    // MARK: - Dependencies
    private var cancellables = Set<AnyCancellable>()
    private let dataService: ProgressDataService
    private let calculationService: ProgressCalculationService
    
    // MARK: - Convenience Properties for Backward Compatibility
    var selectedTab: Tab { state.selectedTab }
    var caloriesData: [Double] { state.chartData.caloriesData }
    var proteinData: [Double] { state.chartData.proteinData }
    var fatData: [Double] { state.chartData.fatData }
    var days: [String] { state.chartData.days }
    var calories: Int { state.nutritionData.calories }
    var protein: Int { state.nutritionData.protein }
    var fat: Int { state.nutritionData.fat }
    var caloriesChange: Int { state.nutritionData.caloriesChange }
    var proteinChange: Int { state.nutritionData.proteinChange }
    var fatChange: Int { state.nutritionData.fatChange }
    var comparisonLabel: String { state.nutritionData.comparisonLabel }
    var isLoading: Bool { state.isLoading }
    
    // MARK: - New Properties for Enhanced State Management
    var loadingState: LoadingState { state.loadingState }
    var hasError: Bool { if case .error = state.loadingState { return true }; return false }
    var isEmpty: Bool { if case .empty = state.loadingState { return true }; return false }
    var errorMessage: String? { state.loadingState.errorMessage }
    var recoverySuggestion: String? { state.loadingState.recoverySuggestion }
    
    // MARK: - Initialization
    
    /// Primary initializer with injected services
    init(dataService: ProgressDataService, calculationService: ProgressCalculationService) {
        self.dataService = dataService
        self.calculationService = calculationService
        setupDataBinding()
        updateData()
    }
    
    /// Convenience initializer for backward compatibility
    convenience init(homeViewModel: HomeViewModel) {
        let dataService = ConcreteProgressDataService(homeViewModel: homeViewModel)
        let calculationService = ConcreteProgressCalculationService()
        self.init(dataService: dataService, calculationService: calculationService)
    }
    
    // MARK: - Public Interface
    
    func selectTab(_ tab: Tab) {
        state = state.copy(selectedTab: tab)
        updateData()
    }
    
    func retry() {
        updateData()
    }
    
    // MARK: - Private Methods
    
    private func setupDataBinding() {
        dataService.savedNutritionPublisher
            .sink { [weak self] _ in self?.updateData() }
            .store(in: &cancellables)
    }
    
    private func updateData() {
        state = state.copy(loadingState: .loading(message: "Calculating progress..."))
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                let result = try self.calculationService.calculateProgress(
                    for: self.state.selectedTab,
                    nutrition: self.dataService.savedNutrition
                )
                
                DispatchQueue.main.async {
                    // Check if we have sufficient data for meaningful charts
                    if result.chartData.isEmpty {
                        self.state = self.state.copy(
                            nutritionData: result.nutritionData,
                            chartData: result.chartData,
                            loadingState: .empty
                        )
                    } else {
                        self.state = self.state.copy(
                            nutritionData: result.nutritionData,
                            chartData: result.chartData,
                            loadingState: .loaded
                        )
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    let progressError = error as? ProgressError ?? ProgressError.unknown(error)
                    self.state = self.state.copy(
                        loadingState: .error(progressError)
                    )
                }
            }
        }
    }
} 