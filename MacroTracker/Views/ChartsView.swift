//
//  ChartsView.swift
//  MacroTracker
//
//  Created by Gorkem on 15.05.2025.
//

import SwiftUI

struct ChartsView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @StateObject private var viewModel: ProgressViewModel
    
    init(dependencyContainer: DependencyContainerProtocol, homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        _viewModel = StateObject(wrappedValue: dependencyContainer.makeProgressViewModel(homeViewModel: homeViewModel))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Progress")
                    .font(.headerTitle)
                    .foregroundStyle(Color.appTitleTintColor)
                Spacer()
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
            
            TabSelector(
                selectedTab: viewModel.selectedTab,
                onTabSelected: viewModel.selectTab
            )
            
            // Content based on loading state
            switch viewModel.loadingState {
            case .loading(let message):
                ProgressLoadingView(message: message)
                
            case .error(let error):
                ProgressErrorView(
                    errorMessage: error.errorDescription ?? "Unknown error",
                    recoverySuggestion: error.recoverySuggestion,
                    onRetry: viewModel.retry
                )
                
            case .empty:
                ProgressEmptyStateView(selectedTab: viewModel.selectedTab)
                
            case .loaded, .idle:
                progressContent
            }
        }
        .foregroundStyle(Color.appTitleTintColor)
        .background(Color("appBackgroundColor").ignoresSafeArea())
    }
    
    private var progressContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                // Calories Section
                EnhancedChartSection(
                    title: "Calories",
                    value: viewModel.calories,
                    change: viewModel.caloriesChange,
                    comparisonLabel: viewModel.comparisonLabel,
                    chartHeight: 120,
                    data: viewModel.caloriesData,
                    days: viewModel.days,
                    onRetry: viewModel.retry
                ) {
                    SafeCaloriesLineChart(
                        data: viewModel.caloriesData,
                        days: viewModel.days
                    )
                }
                
                // Protein Section
                EnhancedChartSection(
                    title: "Protein",
                    value: viewModel.protein,
                    unit: "g",
                    change: viewModel.proteinChange,
                    comparisonLabel: viewModel.comparisonLabel,
                    chartHeight: 100,
                    data: viewModel.proteinData,
                    days: viewModel.days,
                    onRetry: viewModel.retry
                ) {
                    SafeProteinBarChart(
                        data: viewModel.proteinData,
                        days: viewModel.days
                    )
                }
                
                // Fat Section
                EnhancedChartSection(
                    title: "Fat",
                    value: viewModel.fat,
                    unit: "g",
                    change: viewModel.fatChange,
                    comparisonLabel: viewModel.comparisonLabel,
                    chartHeight: 100,
                    data: viewModel.fatData,
                    days: viewModel.days,
                    onRetry: viewModel.retry
                ) {
                    SafeFatBarChart(
                        data: viewModel.fatData,
                        days: viewModel.days
                    )
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Enhanced Chart Section

struct EnhancedChartSection<Chart: View>: View {
    let title: String
    let value: String
    let change: Int
    let comparisonLabel: String
    let chart: Chart
    let chartHeight: CGFloat
    let data: [Double]
    let days: [String]
    let onRetry: () -> Void
    
    init(
        title: String,
        value: String,
        change: Int,
        comparisonLabel: String,
        chartHeight: CGFloat = 100,
        data: [Double],
        days: [String],
        onRetry: @escaping () -> Void,
        @ViewBuilder chart: () -> Chart
    ) {
        self.title = title
        self.value = value
        self.change = change
        self.comparisonLabel = comparisonLabel
        self.chartHeight = chartHeight
        self.data = data
        self.days = days
        self.onRetry = onRetry
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
            .padding(.bottom, 8)
            
            if hasValidData {
                chart
                    .frame(height: chartHeight)
                    .padding(.horizontal)
            } else {
                ChartEmptyView(
                    chartHeight: chartHeight,
                    message: "No \(title.lowercased()) data available"
                )
            }
        }
    }
    
    private var hasValidData: Bool {
        return !data.isEmpty && !days.isEmpty && data.count == days.count
    }
}

// MARK: - Convenience Initializers

extension EnhancedChartSection {
    init(
        title: String,
        value: Int,
        unit: String = "",
        change: Int,
        comparisonLabel: String,
        chartHeight: CGFloat = 100,
        data: [Double],
        days: [String],
        onRetry: @escaping () -> Void,
        @ViewBuilder chart: () -> Chart
    ) {
        let formattedValue = unit.isEmpty ? "\(value)" : "\(value)\(unit)"
        self.init(
            title: title,
            value: formattedValue,
            change: change,
            comparisonLabel: comparisonLabel,
            chartHeight: chartHeight,
            data: data,
            days: days,
            onRetry: onRetry,
            chart: chart
        )
    }
}

// MARK: - Safe Chart Components

// Safe Calories Line Chart
struct SafeCaloriesLineChart: View {
    let data: [Double]
    let days: [String]
    @State private var selectedIdx: Int? = nil
    
    var body: some View {
        if data.isEmpty || days.isEmpty {
            ChartEmptyView(
                chartHeight: 120,
                message: "No calories data to display"
            )
        } else {
            CaloriesLineChart(data: data, days: days)
        }
    }
}

// Safe Protein Bar Chart
struct SafeProteinBarChart: View {
    let data: [Double]
    let days: [String]
    @State private var selectedIdx: Int? = nil
    
    var body: some View {
        if data.isEmpty || days.isEmpty {
            ChartEmptyView(
                chartHeight: 100,
                message: "No protein data to display"
            )
        } else {
            ProteinBarChart(data: data, days: days)
        }
    }
}

// Safe Fat Bar Chart
struct SafeFatBarChart: View {
    let data: [Double]
    let days: [String]
    @State private var selectedIdx: Int? = nil
    
    var body: some View {
        if data.isEmpty || days.isEmpty {
            ChartEmptyView(
                chartHeight: 100,
                message: "No fat data to display"
            )
        } else {
            FatBarChart(data: data, days: days)
        }
    }
}

// MARK: - Enhanced Chart Components with Better Error Handling

// Enhanced Calories Line Chart
struct CaloriesLineChart: View {
    let data: [Double]
    let days: [String]
    @State private var selectedIdx: Int? = nil
    
    var body: some View {
        GeometryReader { geo in
            let maxY = max(data.max() ?? 1, 1) // Ensure maxY is at least 1
            let minY = min(data.min() ?? 0, maxY - 1) // Ensure minY is less than maxY
            let height = max(geo.size.height, 1) // Ensure height is at least 1
            let width = max(geo.size.width, 1) // Ensure width is at least 1
            let count = data.count
            
            if count > 1 && width > 0 && height > 0 {
                let stepX = max(width / CGFloat(count - 1), 0) // Ensure stepX is non-negative
                let points = data.enumerated().map { idx, val in
                    let yRatio = (maxY - minY) > 0 ? (val - minY) / (maxY - minY) : 0
                    return CGPoint(
                        x: max(CGFloat(idx) * stepX, 0), 
                        y: max(height - CGFloat(yRatio) * height, 0)
                    )
                }
                ZStack {
                    // Line
                    Path { path in
                        if let first = points.first {
                            path.move(to: first)
                            for pt in points.dropFirst() {
                                path.addLine(to: pt)
                            }
                        }
                    }
                    .stroke(Color.barChartTintColor, lineWidth: 3)
                    
                    // Tappable points
                    ForEach(points.indices, id: \.self) { idx in
                        let pt = points[idx]
                        Circle()
                            .fill(Color.secondayNumberForegroundColor)
                            .frame(width: 16, height: 16)
                            .opacity(selectedIdx == idx ? 1 : 0.001)
                            .position(pt)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation { selectedIdx = idx }
                            }
                    }
                    // Days labels
                    ForEach(Array(0..<min(data.count, days.count)), id: \.self) { idx in
                        Text(days[idx])
                            .font(.secondaryNumberTitle)
                            .foregroundStyle(Color.secondayNumberForegroundColor)
                            .position(x: max(CGFloat(idx) * stepX, 0), y: height + 12)
                    }
                }
            } else if count == 1 {
                // Single data point
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            Circle()
                                .fill(Color.secondayNumberForegroundColor)
                                .frame(width: 16, height: 16)
                            Text(days.first ?? "")
                                .font(.secondaryNumberTitle)
                                .foregroundStyle(Color.secondayNumberForegroundColor)
                        }
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                ChartEmptyView(
                    chartHeight: height,
                    message: "Not enough data for line chart"
                )
            }
        }
    }
}

// Enhanced Protein Bar Chart (keeping existing implementation but with better error handling)
struct ProteinBarChart: View {
    let data: [Double]
    let days: [String]
    @State private var selectedIdx: Int? = nil
    
    var body: some View {
        GeometryReader { geo in
            let maxY = max(data.max() ?? 1, 1) // Ensure maxY is at least 1
            let height = max(geo.size.height, 1) // Ensure height is at least 1
            let width = max(geo.size.width, 1) // Ensure width is at least 1
            let count = data.count
            if count > 0 && width > 0 && height > 0 {
                let barWidth = max(width / CGFloat(count * 2), 1) // Ensure barWidth is at least 1
                let validIndices = Array(0..<min(data.count, days.count))
                ZStack {
                    ForEach(validIndices, id: \.self) { idx in
                        let val = max(data[idx], 0) // Ensure val is non-negative
                        let barHeight = max(CGFloat(val / maxY) * height, 0) // Ensure barHeight is non-negative
                        let barX = CGFloat(idx) * barWidth * 2 + barWidth
                        VStack(spacing: 0) {
                            Spacer(minLength: max(height - barHeight, 0))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.secondayNumberForegroundColor.opacity(0.2))
                                .frame(width: max(barWidth, 1), height: max(barHeight, 1))
                                .onTapGesture {
                                    withAnimation { selectedIdx = idx }
                                }
                            Text(days[idx])
                                .font(.secondaryNumberTitle)
                                .foregroundStyle(Color.secondayNumberForegroundColor)
                                .frame(width: max(barWidth * 1.2, 1))
                        }
                        .frame(width: max(barWidth * 2, 1), height: max(height, 1), alignment: .bottom)
                        .position(x: barX, y: height / 2)
                    }
                    
                    // Annotation overlay
                    if let idx = selectedIdx, idx < data.count && idx < days.count {
                        let val = max(data[idx], 0)
                        let barHeight = max(CGFloat(val / maxY) * height, 0)
                        let barX = CGFloat(idx) * barWidth * 2 + barWidth
                        let annotationY = height - barHeight - 36
                        BarAnnotationCard(
                            title: formattedDay(idx: idx),
                            value: "\(Int(val))g"
                        )
                        .position(x: barX, y: max(annotationY, 36))
                        
                        // Pointer/line
                        Path { path in
                            let startY = max(annotationY + 18, 54)
                            let endY = height - barHeight
                            path.move(to: CGPoint(x: barX, y: startY))
                            path.addLine(to: CGPoint(x: barX, y: endY))
                        }
                        .stroke(Color.secondayNumberForegroundColor.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [4]))
                    }
                }
            } else {
                ChartEmptyView(
                    chartHeight: height,
                    message: "No protein data available"
                )
            }
        }
    }
    
    func formattedDay(idx: Int) -> String {
        // Example: "Sat, Jun 14"
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: Date().addingTimeInterval(Double(idx) * 86400))
    }
}

// Enhanced Fat Bar Chart (keeping existing implementation but with better error handling)
struct FatBarChart: View {
    let data: [Double]
    let days: [String]
    @State private var selectedIdx: Int? = nil
    
    var body: some View {
        GeometryReader { geo in
            let maxY = max(data.max() ?? 1, 1) // Ensure maxY is at least 1
            let height = max(geo.size.height, 1) // Ensure height is at least 1
            let width = max(geo.size.width, 1) // Ensure width is at least 1
            let count = data.count
            if count > 0 && width > 0 && height > 0 {
                let barWidth = max(width / CGFloat(count * 2), 1) // Ensure barWidth is at least 1
                let validIndices = Array(0..<min(data.count, days.count))
                ZStack {
                    ForEach(validIndices, id: \.self) { idx in
                        let val = max(data[idx], 0) // Ensure val is non-negative
                        let barHeight = max(CGFloat(val / maxY) * height, 0) // Ensure barHeight is non-negative
                        let barX = CGFloat(idx) * barWidth * 2 + barWidth
                        VStack(spacing: 0) {
                            Spacer(minLength: max(height - barHeight, 0))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.secondayNumberForegroundColor.opacity(0.2))
                                .frame(width: max(barWidth, 1), height: max(barHeight, 1))
                                .onTapGesture {
                                    withAnimation { selectedIdx = idx }
                                }
                            Text(days[idx])
                                .font(.secondaryNumberTitle)
                                .foregroundStyle(Color.secondayNumberForegroundColor)
                                .frame(width: max(barWidth * 1.2, 1))
                        }
                        .frame(width: max(barWidth * 2, 1), height: max(height, 1), alignment: .bottom)
                        .position(x: barX, y: height / 2)
                    }
                    
                    // Annotation overlay
                    if let idx = selectedIdx, idx < data.count && idx < days.count {
                        let val = max(data[idx], 0)
                        let barHeight = max(CGFloat(val / maxY) * height, 0)
                        let barX = CGFloat(idx) * barWidth * 2 + barWidth
                        let annotationY = height - barHeight - 36
                        BarAnnotationCard(
                            title: formattedDay(idx: idx),
                            value: "\(Int(val))g"
                        )
                        .position(x: barX, y: max(annotationY, 36))
                        
                        // Pointer/line
                        Path { path in
                            let startY = max(annotationY + 18, 54)
                            let endY = height - barHeight
                            path.move(to: CGPoint(x: barX, y: startY))
                            path.addLine(to: CGPoint(x: barX, y: endY))
                        }
                        .stroke(Color.secondayNumberForegroundColor.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [4]))
                    }
                }
            } else {
                ChartEmptyView(
                    chartHeight: height,
                    message: "No fat data available"
                )
            }
        }
    }
    
    func formattedDay(idx: Int) -> String {
        // Example: "Sat, Jun 14"
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: Date().addingTimeInterval(Double(idx) * 86400))
    }
}
