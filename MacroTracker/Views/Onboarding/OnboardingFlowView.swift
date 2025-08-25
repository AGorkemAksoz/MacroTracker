import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject var onboardingManager: OnboardingManager
    @State private var currentPage = 0
    
    private let onboardingPages = [
        OnboardingPage(
            image: "onboard1",
            title: "Welcome To BiteWise",
            description: "Effortlessly track your nutrition and achieve your health goals."
        ),
        OnboardingPage(
            image: "onboard2", 
            title: "Log your meals quickly",
            description: "Track your daily meals and nutritional intake with ease. Our app simplifies the process, allowing you to focus on your health goals."
        ),
        OnboardingPage(
            image: "onboard3",
            title: "Achieve your health goals with ease",
            description: "Track your meals, monitor your nutrition, and stay on course with our simple, intuitive app."
        )
    ]
    
    var body: some View {
        ZStack {
            Color("appBackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        OnboardingPageView(page: onboardingPages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Progress dots
                progressDots
                
                // Button
                actionButton
            }
        }
    }
    
    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<onboardingPages.count, id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? 
                          Color.confirmButtonBackgroudColor : 
                          Color.confirmButtonBackgroudColor.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut, value: currentPage)
            }
        }
        .padding(.top, 60)
        .padding(.bottom, 20)
    }
    
    private var actionButton: some View {
        Button {
            if currentPage < onboardingPages.count - 1 {
                withAnimation {
                    currentPage += 1
                }
            } else {
                onboardingManager.completeOnboarding()
            }
        } label: {
            Text(currentPage < onboardingPages.count - 1 ? "Next" : "Get Started")
                .font(.confirmButtonTitle)
                .frame(width: UIScreen.main.bounds.width * 0.85)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.confirmButtonBackgroudColor)
                )
                .foregroundColor(Color.confirmButtonForegroudColor)
        }
        .padding(.bottom, 50)
    }
}

struct OnboardingPage {
    let image: String
    let title: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Spacer()
            
            Image(page.image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 300)
                .padding(.horizontal)
            
            Text(page.title)
                .font(.onboardingHeaderTitle)
                .foregroundStyle(Color.onboardHeaderTintColor)
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.foodDateLabel)
                .foregroundStyle(Color.onboardHeaderTintColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingFlowView()
}
