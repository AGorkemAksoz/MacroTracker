//
//  TabSelector.swift
//  MacroTracker
//
//  Created by Gorkem on 18.05.2025.
//

import SwiftUI

struct TabSelector<TabType: CaseIterable & Hashable>: View {
    let tabs: [TabType]
    let selectedTab: TabType
    let onTabSelected: (TabType) -> Void
    let tabTitle: (TabType) -> String
    
    var body: some View {
        HStack(spacing: 24) {
            ForEach(tabs, id: \.self) { tab in
                Button(action: { onTabSelected(tab) }) {
                    VStack(spacing: 2) {
                        Text(tabTitle(tab))
                            .font(.primaryTitle)
                            .foregroundStyle(selectedTab == tab ? Color.appForegroundColor : Color.secondayNumberForegroundColor)
                        Rectangle()
                            .frame(height: 2)
                            .foregroundStyle(selectedTab == tab ? Color.appForegroundColor : Color.clear)
                    }
                }
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Convenience Extension for ProgressViewModel.Tab

extension TabSelector where TabType == ProgressViewModel.Tab {
    init(selectedTab: ProgressViewModel.Tab, onTabSelected: @escaping (ProgressViewModel.Tab) -> Void) {
        self.tabs = ProgressViewModel.Tab.allCases
        self.selectedTab = selectedTab
        self.onTabSelected = onTabSelected
        self.tabTitle = { tab in
            switch tab {
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            }
        }
    }
}

#Preview {
    TabSelector(
        selectedTab: ProgressViewModel.Tab.weekly,
        onTabSelected: { _ in }
    )
    .padding()
} 