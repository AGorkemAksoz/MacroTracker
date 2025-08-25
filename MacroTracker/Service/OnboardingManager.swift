import Foundation

class OnboardingManager: ObservableObject {
    @Published var shouldShowOnboarding: Bool = false
    
    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    
    init() {
        checkOnboardingStatus()
    }
    
    private func checkOnboardingStatus() {
        shouldShowOnboarding = !UserDefaults.standard.bool(forKey: hasSeenOnboardingKey)
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: hasSeenOnboardingKey)
        shouldShowOnboarding = false
    }
}
