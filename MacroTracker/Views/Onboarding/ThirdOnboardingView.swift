//
//  ThirdOnboardingView.swift
//  MacroTracker
//
//  Created by Gorkem on 22.08.2025.
//

import SwiftUI

struct ThirdOnboardingView: View {
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 8) {
                Image("onboard3")
                    .resizable()
                    .scaledToFit()
                
                Text("Achive your health goals with ease")
                    .font(.onboardingHeaderTitle)
                    .foregroundStyle(Color.onboardHeaderTintColor)
                
                Text("Track your meals, monitor your nutrition, and stay on course with out simple, intuitive app.")
                    .font(.foodDateLabel)
                    .foregroundStyle(Color.onboardHeaderTintColor)
                    .padding()
                
                Spacer()
                
                enteringButton
            }
            .multilineTextAlignment(.center)
        }
        .background(Color("appBackgroundColor").ignoresSafeArea())
    }
}

#Preview {
    ThirdOnboardingView()
}

extension ThirdOnboardingView {
    private var enteringButton: some View {
        Button {
            
        } label: {
            HStack(spacing: 12) {
                Text("Done")
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
