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

// MARK: - Progress View Model

class ProgressViewModel: ObservableObject {
    
    enum Tab: String, CaseIterable {
        case weekly = "Last 7 Days"
        case monthly = "Last 30 Days"
    }
    
    // MARK: - State & Properties
    
    @Published private(set) var state = ProgressState.initial
    
    private let dataService: ProgressDataService
    private let calculationService: ProgressCalculationService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(dataService: ProgressDataService, calculationService: ProgressCalculationService) {
        self.dataService = dataService
        self.calculationService = calculationService
        
        // Initial data fetch
        updateData()
        
        // Listen for data changes from HomeViewModel
        dataService.savedNutritionPublisher
            .dropFirst() // Ignore the initial value
            .sink { [weak self] _ in
                self?.updateData()
            }
            .store(in: &cancellables)
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

// MARK: - Computed Properties
extension ProgressViewModel {
    var selectedTab: Tab {
        state.selectedTab
    }
    
    var loadingState: LoadingState {
        state.loadingState
    }
    
    var calories: Int {
        state.nutritionData.calories
    }
    
    var protein: Int {
        state.nutritionData.protein
    }
    
    var fat: Int {
        state.nutritionData.fat
    }
    
    var caloriesChange: Int {
        state.nutritionData.caloriesChange
    }
    
    var proteinChange: Int {
        state.nutritionData.proteinChange
    }
    
    var fatChange: Int {
        state.nutritionData.fatChange
    }
    
    var comparisonLabel: String {
        state.nutritionData.comparisonLabel
    }
    
    var caloriesData: [Double] {
        state.chartData.caloriesData
    }
    
    var proteinData: [Double] {
        state.chartData.proteinData
    }
    
    var fatData: [Double] {
        state.chartData.fatData
    }
    
    var days: [String] {
        state.chartData.days
    }
} 
