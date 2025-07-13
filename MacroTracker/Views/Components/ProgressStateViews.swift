//
//  ProgressStateViews.swift
//  MacroTracker
//
//  Created by Gorkem on 12.07.2025.
//

import SwiftUI

// MARK: - Progress Loading View

struct ProgressLoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle())
            
            Text(message)
                .font(.primaryTitle)
                .foregroundStyle(Color.secondayNumberForegroundColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Progress Error View

struct ProgressErrorView: View {
    let errorMessage: String
    let recoverySuggestion: String?
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.red)
            
            VStack(spacing: 8) {
                Text("Something went wrong")
                    .font(.primaryTitle)
                    .foregroundStyle(Color.appForegroundColor)
                
                Text(errorMessage)
                    .font(.secondaryNumberTitle)
                    .foregroundStyle(Color.secondayNumberForegroundColor)
                    .multilineTextAlignment(.center)
                
                if let suggestion = recoverySuggestion {
                    Text(suggestion)
                        .font(.secondaryNumberTitle)
                        .foregroundStyle(Color.secondayNumberForegroundColor)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
            
            Button(action: onRetry) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.primaryTitle)
                .foregroundStyle(Color.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.appForegroundColor)
                .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Progress Empty State View

struct ProgressEmptyStateView: View {
    let selectedTab: ProgressViewModel.Tab
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundStyle(Color.secondayNumberForegroundColor)
            
            VStack(spacing: 8) {
                Text("No Progress Data")
                    .font(.primaryTitle)
                    .foregroundStyle(Color.appForegroundColor)
                
                Text(emptyStateMessage)
                    .font(.secondaryNumberTitle)
                    .foregroundStyle(Color.secondayNumberForegroundColor)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                Text("Get started by:")
                    .font(.secondaryNumberTitle)
                    .foregroundStyle(Color.secondayNumberForegroundColor)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "1.circle.fill")
                            .foregroundStyle(Color.appForegroundColor)
                        Text("Log your meals daily")
                            .font(.secondaryNumberTitle)
                            .foregroundStyle(Color.secondayNumberForegroundColor)
                    }
                    
                    HStack {
                        Image(systemName: "2.circle.fill")
                            .foregroundStyle(Color.appForegroundColor)
                        Text("Track for at least \(minimumDaysText)")
                            .font(.secondaryNumberTitle)
                            .foregroundStyle(Color.secondayNumberForegroundColor)
                    }
                    
                    HStack {
                        Image(systemName: "3.circle.fill")
                            .foregroundStyle(Color.appForegroundColor)
                        Text("View your progress here")
                            .font(.secondaryNumberTitle)
                            .foregroundStyle(Color.secondayNumberForegroundColor)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var emptyStateMessage: String {
        switch selectedTab {
        case .weekly:
            return "Start logging your meals to see your weekly progress trends and nutritional patterns."
        case .monthly:
            return "Log meals consistently to view your monthly progress and long-term nutritional trends."
        }
    }
    
    private var minimumDaysText: String {
        switch selectedTab {
        case .weekly:
            return "3-4 days"
        case .monthly:
            return "2-3 weeks"
        }
    }
}

// MARK: - Enhanced Chart Loading Placeholder

struct ChartLoadingPlaceholder: View {
    let chartHeight: CGFloat
    let chartType: ChartType
    
    enum ChartType {
        case line
        case bar
        
        var placeholderIcon: String {
            switch self {
            case .line:
                return "chart.line.uptrend.xyaxis"
            case .bar:
                return "chart.bar"
            }
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.containerBackgroundColor.opacity(0.3))
                .frame(height: chartHeight)
            
            VStack(spacing: 8) {
                Image(systemName: chartType.placeholderIcon)
                    .font(.system(size: 24))
                    .foregroundStyle(Color.secondayNumberForegroundColor.opacity(0.5))
                
                Text("Loading chart...")
                    .font(.secondaryNumberTitle)
                    .foregroundStyle(Color.secondayNumberForegroundColor.opacity(0.5))
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Enhanced Chart Error View

struct ChartErrorView: View {
    let chartHeight: CGFloat
    let error: String
    let onRetry: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.1))
                .frame(height: chartHeight)
            
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.red)
                
                Text("Chart Error")
                    .font(.secondaryNumberTitle)
                    .foregroundStyle(Color.red)
                
                Button("Retry") {
                    onRetry()
                }
                .font(.secondaryNumberTitle)
                .foregroundStyle(Color.appForegroundColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.containerBackgroundColor)
                .cornerRadius(6)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Enhanced Chart Empty View

struct ChartEmptyView: View {
    let chartHeight: CGFloat
    let message: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.containerBackgroundColor.opacity(0.3))
                .frame(height: chartHeight)
            
            VStack(spacing: 8) {
                Image(systemName: "chart.line.flattrend.xyaxis")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.secondayNumberForegroundColor.opacity(0.5))
                
                Text(message)
                    .font(.secondaryNumberTitle)
                    .foregroundStyle(Color.secondayNumberForegroundColor.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 32) {
        ProgressLoadingView(message: "Calculating progress...")
            .frame(height: 200)
        
        ProgressErrorView(
            errorMessage: "Unable to calculate progress",
            recoverySuggestion: "Please try again or restart the app",
            onRetry: {}
        )
        .frame(height: 200)
        
        ProgressEmptyStateView(selectedTab: .weekly)
            .frame(height: 200)
        
        ChartLoadingPlaceholder(chartHeight: 120, chartType: .line)
        
        ChartErrorView(chartHeight: 120, error: "Data error", onRetry: {})
        
        ChartEmptyView(chartHeight: 120, message: "No data available")
    }
    .padding()
} 