//
//  SecondOnboardingView.swift
//  MacroTracker
//
//  Created by Gorkem on 22.08.2025.
//

import SwiftUI

struct SecondOnboardingView: View {
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 8) {
                Image("onboard2")
                    .resizable()
                    .scaledToFit()
                
                Text("Log your meals quickly")
                    .font(.onboardingHeaderTitle)
                    .foregroundStyle(Color.onboardHeaderTintColor)
                Text("Track your daily meals and nutritional intake with ease. Our app simplifies the process, allowing you to focus on your health goals.")
                    .font(.foodDateLabel)
                    .foregroundStyle(Color.onboardHeaderTintColor)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
                enteringButton
            }
        }
        .background(Color("appBackgroundColor").ignoresSafeArea())
    }
}

#Preview {
    SecondOnboardingView()
}

extension SecondOnboardingView {
    private var enteringButton: some View {
        Button {
            
        } label: {
            HStack(spacing: 12) {
                Text("Next")
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
