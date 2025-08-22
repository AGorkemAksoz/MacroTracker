//
//  FirstOnboardingView.swift
//  MacroTracker
//
//  Created by Gorkem on 22.08.2025.
//

import SwiftUI

struct FirstOnboardingView: View {
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 8) {
                Text("Welcome To BiteWise")
                    .font(.onboardingHeaderTitle)
                    .foregroundStyle(Color.onboardHeaderTintColor)
                Text("Effortlessly track your nutrition and achieve your health goals.")
                    .font(.foodDateLabel)
                    .foregroundStyle(Color.onboardHeaderTintColor)
                    .multilineTextAlignment(.center)
                Image("onboard1")
                    .resizable()
                    .scaledToFit()
                    .padding()
                enteringButton
            }
        }
        .background(Color("appBackgroundColor")).ignoresSafeArea()
    }
}

#Preview {
    FirstOnboardingView()
}

extension FirstOnboardingView {
    private var enteringButton: some View {
        Button {
            
        } label: {
            HStack(spacing: 12) {
                Text("Get Started")
                    .font(.confirmButtonTitle)
            }
            .frame(width: UIScreen.main.bounds.width * 0.85)
            .frame(height: 48)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(                         Color.confirmButtonBackgroudColor))
            .foregroundColor(Color.confirmButtonForegroudColor)
            .padding(.horizontal)
            .animation(.easeInOut(duration: 0.5))
        }
    }
}
