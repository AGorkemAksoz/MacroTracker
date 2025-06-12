import SwiftUI

class NavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var presentedSheet: SheetRoute?
    
    // MARK: - Navigation Methods
    
    func navigate(to route: AppRoute) {
        path.append(route)
    }
    
    func navigateBack() {
        path.removeLast()
    }
    
    func navigateToRoot() {
        path.removeLast(path.count)
    }
    
    func presentSheet(_ route: SheetRoute) {
        presentedSheet = route
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
}

// MARK: - Sheet Routes
enum SheetRoute: Identifiable {
    case settings
    case profile
    
    var id: String { String(describing: self) }
}

// MARK: - Environment Key
struct NavigationCoordinatorKey: EnvironmentKey {
    static let defaultValue: NavigationCoordinator = NavigationCoordinator()
}

extension EnvironmentValues {
    var navigationCoordinator: NavigationCoordinator {
        get { self[NavigationCoordinatorKey.self] }
        set { self[NavigationCoordinatorKey.self] = newValue }
    }
} 