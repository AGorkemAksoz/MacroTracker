//
//  HomeView.swift
//  MacroTracker
//
//  Created by Gorkem on 17.03.2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel(nutritionService: NutritionService())
    var body: some View {
        Text("Hello, World!")
            .onAppear {
                homeViewModel.fetchNutrition()
            }
    }
}

#Preview {
    HomeView()
}
