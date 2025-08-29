# MacroTracker - Developer Guide & Architecture Documentation

## �� Welcome, Developer!

This guide is designed to help you understand and contribute to the MacroTracker codebase. Whether you're a new team member, open-source contributor, or just exploring the project, this documentation will get you up to speed quickly.

## 📋 Quick Start for New Developers

### What is MacroTracker?
MacroTracker is a SwiftUI-based nutrition tracking app that helps users monitor their daily food intake and nutritional goals. Think of it as a personal nutritionist in your pocket!

### Key Features You'll Work With:
- 🍽️ **Meal Tracking**: Users log breakfast, lunch, dinner, and snacks
- 📊 **Progress Charts**: Visual analytics showing weekly/monthly nutrition trends
- 🔍 **Food Search**: Real-time food database integration
- 📱 **Onboarding**: First-time user experience
- 💾 **Offline Support**: Works without internet using local storage

---

## 🏗️ Architecture Overview - The Big Picture

Imagine the app as a well-organized restaurant:
┌─────────────────────────────────────────────────────────────┐
│ 🏪 MacroTracker Restaurant │
├─────────────────────────────────────────────────────────────┤
│ �� Front of House (UI Layer) │
│ ┌──────────────┐ ┌──────────────┐ ┌──────────────────┐ │
│ │ 🏠 Home │ │ 📊 Charts │ │ �� Food Search │ │
│ │ (Main View)│ │ (Analytics) │ │ (Find Foods) │ │
│ └──────────────┘ └──────────────┘ └──────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│ 👨‍💼 Management (Business Logic) │
│ ┌──────────────┐ ┌──────────────┐ ┌──────────────────┐ │
│ │ HomeManager │ │ChartManager │ │ SearchManager │ │
│ │(Daily Meals) │ │(Calculations)│ │ (API Calls) │ │
│ └──────────────┘ └──────────────┘ └──────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│ 🗄️ Back of House (Data Layer) │
│ ┌──────────────┐ ┌──────────────┐ ┌──────────────────┐ │
│ │ 📱 Local DB │ │ �� Internet │ │ �� Cache Store │ │
│ │(SwiftData) │ │(Food API) │ │ (Quick Access) │ │
│ └──────────────┘ └──────────────┘ └──────────────────┘ │
└─────────────────────────────────────────────────────────────┘

### How Data Flows (The Customer Journey):
1. **User opens app** → Onboarding (if first time) → Main screen
2. **User searches for food** → API call → Results displayed
3. **User adds food to meal** → Saved to local database → Charts update
4. **User views progress** → Data calculated → Charts rendered

---

## 📁 Project Structure - Where to Find Things

MacroTracker/
├── 🚀 MacroTrackerApp.swift # App starts here (like main() function)
├── 📱 Views/ # All the screens users see
│ ├── 🏠 Home/ # Main dashboard
│ ├── 📊 ChartsView.swift # Progress charts
│ ├── 🎭 Onboarding/ # First-time user experience
│ ├── 🔍 EnteringFood/ # Food search & selection
│ ├── 📋 Detail/ # Detailed meal views
│ ├── 🧩 Components/ # Reusable UI pieces
│ └── 🎨 Common/ # Shared UI elements
├── 🧠 Service/ # Business logic (the brains)
├── 🌐 Network/ # Internet communication
├── 💾 Database/ # Local data storage
├── 📦 Entities/ # Data models (like database tables)
├── 🧭 Navigation/ # Screen navigation logic
├── 🔧 Extension/ # Swift language extensions
└── 📊 ViewData/ # Data structures for UI

### Quick Navigation Tips:
- **Need to change a screen?** → Look in `Views/`
- **Need to fix business logic?** → Look in `Service/`
- **Need to add new data?** → Look in `Entities/`
- **Need to change navigation?** → Look in `Navigation/`

---

## 🎯 Core Concepts - Understanding the Architecture

### 1. MVVM Pattern (Model-View-ViewModel)
Think of it as a three-layer cake:
┌─────────────────┐
│ 🎨 View │ ← What users see (SwiftUI)
├─────────────────┤
│ 🧠 ViewModel │ ← Business logic & data preparation
├─────────────────┤
│ 📦 Model │ ← Data structure & storage
└─────────────────┘


**Real Example:**
- **View**: `HomeView.swift` (shows the meal list)
- **ViewModel**: `HomeViewModel.swift` (manages meal data)
- **Model**: `FoodItem.swift` (defines what a food item looks like)

### 2. Dependency Injection
Instead of creating objects directly, we pass them in (like ordering ingredients):

```swift
// ❌ Bad: Creating dependencies inside
class HomeViewModel {
    private let repository = NutritionRepository() // Hard to test!
}

// ✅ Good: Dependencies injected from outside
class HomeViewModel {
    private let repository: NutritionRepositoryInterface
    
    init(repository: NutritionRepositoryInterface) {
        self.repository = repository // Easy to test with mocks!
    }
}
```

### 3. Repository Pattern
A single interface for all data operations (like a restaurant manager):

```swift
protocol NutritionRepositoryInterface {
    func getAllFoodItems() -> [FoodItem]           // Get all saved foods
    func saveFoodItems(_ items: [Item]) -> Bool    // Save new foods
    func searchNutrition(query: String) -> AnyPublisher<[Item], Error> // Search online
}
```

---

## 🔧 Key Components Deep Dive

### 1. App Entry Point (`MacroTrackerApp.swift`)

This is where everything starts. Think of it as the restaurant's grand opening:

```swift
@main
struct MacroTrackerApp: App {
    // ��️ Setup the kitchen (database)
    let modelContainer: ModelContainer
    
    // 👥 Hire the staff (services)
    let dependencyContainer: DependencyContainerProtocol
    
    // 🎭 Manage the front desk (navigation & onboarding)
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    @StateObject private var onboardingManager = OnboardingManager()
    
    var body: some Scene {
        WindowGroup {
            Group {
                // 🎬 Show onboarding for new customers
                if onboardingManager.shouldShowOnboarding {
                    OnboardingFlowView()
                } else {
                    // 🏠 Show main restaurant
                    MainTabView(dependencyContainer: dependencyContainer)
                }
            }
        }
    }
}
```

**What happens here:**
1. App starts → Check if user is new
2. If new → Show onboarding screens
3. If returning → Show main app

### 2. Main Tab View (`MainTabView.swift`)

The main navigation hub (like a restaurant with different dining areas):

```swift
struct MainTabView: View {
    var body: some View {
        TabView {
            // 🏠 Home - Daily meal tracking
            HomeView(homeViewModel: sharedHomeViewModel)
                .tabItem {
                    Image(systemName: "house")
                    Text("Dashboard")
                }
            
            // 📊 Charts - Progress analytics
            ChartsView(dependencyContainer: dependencyContainer, homeViewModel: sharedHomeViewModel)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Progress")
                }
        }
    }
}
```

### 3. Home View (`HomeView.swift`)

The main dashboard where users see their daily meals:

```swift
struct HomeView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 📅 Date selector
                    dateSelector
                    
                    // 🍽️ List of today's meals
                    dailyMealsList
                    
                    // ➕ Add meal button
                    addMealButton
                }
            }
        }
    }
}
```

**Key Features:**
- Shows meals for selected date
- Allows adding new meals
- Navigates to meal details
- Updates in real-time

### 4. Charts View (`ChartsView.swift`)

The analytics dashboard showing nutrition progress:

```swift
struct ChartsView: View {
    @StateObject private var viewModel: ProgressViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // �� Weekly/Monthly tab selector
                tabSelector
                
                // 📈 Progress charts
                progressContent
            }
        }
    }
}
```

**What it shows:**
- Calories over time (line chart)
- Protein intake (bar chart)
- Fat intake (bar chart)
- Percentage changes vs previous period

---

## 🧠 Business Logic Layer - The Brains

### HomeViewModel - Daily Meal Manager

Think of this as the restaurant manager who keeps track of daily operations:

```swift
class HomeViewModel: ObservableObject {
    // 📊 Current state (what the UI shows)
    @Published private(set) var dailyMeals: [DailyMealData] = []
    @Published private(set) var selectedDate: Date = Date()
    
    // 🧠 Business logic services
    private let nutritionRepository: NutritionRepositoryInterface
    private let modelContext: ModelContext
    
    // �� Main functions
    func loadDailyMeals()           // Load today's meals
    func selectDate(_ date: Date)   // Change to different day
    func deleteFoodItem(_ foodItem: FoodItem)  // Remove a food item
}
```

**What it does:**
- Manages the list of meals for a specific date
- Handles adding/removing food items
- Updates the UI when data changes
- Coordinates with the database

### ProgressViewModel - Analytics Calculator

This is like the restaurant's accountant who calculates all the metrics:

```swift
class ProgressViewModel: ObservableObject {
    // 📊 Single source of truth for all progress data
    @Published private(set) var state = ProgressState.initial
    
    // 🧮 Services for calculations
    private let dataService: ProgressDataService
    private let calculationService: ProgressCalculationService
    
    // �� Main functions
    func selectTab(_ tab: Tab)      // Switch between Weekly/Monthly
    func retry()                    // Retry if calculation fails
}
```

**What it calculates:**
- Daily calorie averages
- Protein/fat/carb trends
- Percentage changes over time
- Chart data for visualization

---

## �� Data Layer - Where Information Lives

### SwiftData Entities - The Database Tables

Think of these as the restaurant's inventory system:

```swift
@Model
class FoodItem {
    var id: UUID                    // Unique identifier
    var name: String                // Food name (e.g., "Chicken Breast")
    var calories: Int               // Calorie content
    var protein: Double             // Protein grams
    var fat: Double                 // Fat grams
    var carbs: Double               // Carbohydrate grams
    var date: Date                  // When it was eaten
    var mealType: MealTypes         // Breakfast/Lunch/Dinner/Snack
}
```

**MealTypes Enum:**
```swift
enum MealTypes: String, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
}
```

### Repository Pattern - The Data Manager

This is like having a smart inventory manager who knows where everything is:

```swift
protocol NutritionRepositoryInterface {
    // 📖 Read operations
    func getAllFoodItems() -> [FoodItem]
    func getFoodItems(for date: Date) -> [FoodItem]
    
    // ✏️ Write operations
    func saveFoodItems(_ items: [Item], date: Date, mealType: MealTypes) -> Bool
    func deleteFoodItem(_ foodItem: FoodItem)
    
    // �� Network operations
    func searchNutrition(query: String) -> AnyPublisher<[Item], Error>
}
```

**Why this pattern?**
- **Single Interface**: One way to access all data
- **Multiple Sources**: Can get data from local DB or internet
- **Easy Testing**: Can swap real implementation with mock
- **Consistent API**: Same methods regardless of data source

---

## 🌐 Network Layer - Talking to the Internet

### API Client - The Internet Communicator

This handles all communication with external services (like the food database):

```swift
class APIClient<EndpointType: APIEndpoint>: APIClientInterface {
    func request<T>(_ endpoint: EndpointType) -> AnyPublisher<T, Error> where T : Decodable {
        // 1. Create the request
        var urlRequest = URLRequest(url: endpoint.url!)
        urlRequest.httpMethod = endpoint.method.rawValue
        
        // 2. Add headers (like API key)
        if let headers = endpoint.headers {
            for (key, value) in headers {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // 3. Make the request and handle response
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else { 
                    throw APIError.invalidResponse
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
```

### Nutrition Endpoint - The Food Search API

This defines how we talk to the CalorieNinjas food database:

```swift
enum NutritionEndpoint: APIEndpoint {
    case getNutrition(query: String)
    
    var baseURL: URL { URL(string: "https://api.calorieninjas.com")! }
    var path: String { "/v1/nutrition" }
    var method: HTTPMethod { .get }
    var headers: [String: String]? { ["X-Api-Key": APIKeyProvider.apiKey] }
    
    var url: URL? {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        
        switch self {
        case .getNutrition(let query):
            components.queryItems = [URLQueryItem(name: "query", value: query)]
        }
        
        return components.url
    }
}
```

**What it does:**
- Takes a food name (e.g., "apple")
- Sends request to CalorieNinjas API
- Returns nutrition information (calories, protein, etc.)

---

## 🧭 Navigation System - Getting Around the App

### NavigationCoordinator - The App's GPS

This manages how users move between screens:

```swift
class NavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath()           // Current navigation stack
    @Published var presentedSheet: SheetRoute?       // Modal sheets
    
    // �� Navigation methods
    func navigate(to route: AppRoute)                // Go to a screen
    func navigateBack()                              // Go back
    func navigateToRoot()                            // Go to home
    func presentSheet(_ route: SheetRoute)           // Show modal
    func dismissSheet()                              // Hide modal
}
```

### AppRoute - The Map of Screens

This defines all the places users can go:

```swift
enum AppRoute: Hashable {
    case home                                        // Main dashboard
    case enterFood                                   // Food search screen
    case confirmFood(foods: [Item], date: Date, mealType: MealTypes)  // Confirm selection
    case dailyMealDetail(date: Date)                 // Day's meal details
    case mealTypeDetail(type: MealTypes, meals: [FoodItem], date: Date)  // Meal type details
    case foodDetail(food: FoodItem)                  // Individual food details
}
```

**How navigation works:**
1. User taps "Add Food" → `navigate(to: .enterFood)`
2. User selects food → `navigate(to: .confirmFood(...))`
3. User confirms → `navigateBack()` to home

---

## 🎭 Onboarding System - First-Time User Experience

### OnboardingManager - The Welcome Committee

This handles the first-time user experience:

```swift
class OnboardingManager: ObservableObject {
    @Published var shouldShowOnboarding: Bool = false
    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    
    init() {
        checkOnboardingStatus()  // Check if user has seen onboarding
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: hasSeenOnboardingKey)
        shouldShowOnboarding = false
    }
}
```

**How it works:**
1. App starts → Check UserDefaults for onboarding flag
2. If flag doesn't exist → Show onboarding screens
3. User completes onboarding → Save flag, never show again

### OnboardingFlowView - The Welcome Tour

Three screens that introduce the app:

```swift
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
            description: "Track your daily meals and nutritional intake with ease."
        ),
        OnboardingPage(
            image: "onboard3",
            title: "Achieve your health goals with ease",
            description: "Track your meals, monitor your nutrition, and stay on course."
        )
    ]
}
```

---

## 🔧 Dependency Management - Connecting the Pieces

### DependencyContainer - The Assembly Line

This is like a factory that creates all the components and connects them:

```swift
protocol DependencyContainerProtocol {
    var nutritionRepository: NutritionRepositoryInterface { get }
    var modelContext: ModelContext { get }
    
    func makeHomeViewModel() -> HomeViewModel
    func makeProgressViewModel(homeViewModel: HomeViewModel) -> ProgressViewModel
}

class DependencyContainer: DependencyContainerProtocol {
    let nutritionRepository: NutritionRepositoryInterface
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        // 🏭 Create all the services
        let databaseService = NutritionDatabaseService(modelContext: modelContext)
        let networkService = NutritionService()
        let cacheService = NutritionCacheService()
        
        // 🔗 Connect them together
        self.nutritionRepository = NutritionRepository(
            databaseService: databaseService,
            networkService: networkService,
            cacheService: cacheService
        )
    }
    
    // 🎯 Factory methods for ViewModels
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            nutritionRepository: nutritionRepository,
            modelContext: modelContext
        )
    }
}
```

**Why this pattern?**
- **Centralized Creation**: All dependencies created in one place
- **Easy Testing**: Can swap real services with mocks
- **Loose Coupling**: Components don't create their own dependencies
- **Consistency**: Same services used throughout the app

---

## �� UI Components - Reusable Building Blocks

### Common Components - The Lego Blocks

These are reusable UI pieces used throughout the app:

```swift
// 📊 Shows daily calorie summary
struct CaloriesSummary: View {
    let calories: Int
    let targetCalories: Int
}

// �� Shows protein, fat, carbs breakdown
struct MacroSummary: View {
    let protein: Double
    let fat: Double
    let carbs: Double
}

// 🍽️ Shows individual meal type
struct IconCell: View {
    let mealType: MealTypes
    let foodCount: Int
    let totalCalories: Int
}
```

### Chart Components - The Analytics Tools

Specialized components for data visualization:

```swift
// 📈 Chart container with title and data
struct ChartSection<Chart: View>: View {
    let title: String
    let value: String
    let change: Int
    let chart: Chart
}

// 📊 Progress card showing nutrition data
struct ProgressNutritionCard: View {
    let title: String
    let value: String
    let change: Int
    let comparisonLabel: String
}
```

---

## 🚀 How to Add New Features - A Practical Guide

### Scenario: Adding a New Meal Type

Let's say you want to add "Dessert" as a new meal type:

#### Step 1: Update the Data Model
```swift
// In Entities/FoodItem.swift or wherever MealTypes is defined
enum MealTypes: String, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    case dessert = "Dessert"  // 🆕 Add this line
}
```

#### Step 2: Update the UI
```swift
// In Views/Common/IconCell.swift or similar
struct IconCell: View {
    let mealType: MealTypes
    
    var body: some View {
        HStack {
            // 🆕 Add dessert icon
            switch mealType {
            case .breakfast: Image("breakfastIcon")
            case .lunch: Image("lunchIcon")
            case .dinner: Image("dinnerIcon")
            case .snack: Image("snackIcon")
            case .dessert: Image("dessertIcon")  // 🆕 Add this case
            }
            
            Text(mealType.mealName)
        }
    }
}
```

#### Step 3: Test the Feature
```swift
// In your ViewModel or wherever meal types are used
let mealTypes = MealTypes.allCases  // Will now include dessert
```

### Scenario: Adding a New Chart Type

#### Step 1: Create the Chart Component
```swift
// In Views/Components/ or create new file
struct CarbohydrateChart: View {
    let data: [Double]
    let days: [String]
    
    var body: some View {
        // Your chart implementation
        Chart {
            ForEach(Array(zip(data, days).enumerated()), id: \.offset) { index, item in
                BarMark(
                    x: .value("Day", item.1),
                    y: .value("Carbs", item.0)
                )
            }
        }
    }
}
```

#### Step 2: Add to ProgressViewModel
```swift
// In Service/ProgressCalculationService.swift
struct ProgressCalculationResult {
    let caloriesData: [Double]
    let proteinData: [Double]
    let fatData: [Double]
    let carbsData: [Double]  // 🆕 Add this
    let days: [String]
}
```

#### Step 3: Update the UI
```swift
// In Views/ChartsView.swift
private var progressContent: some View {
    VStack(spacing: 32) {
        // Existing charts...
        
        // 🆕 Add new chart
        ChartSection(title: "Carbohydrates", value: "\(viewModel.carbsTotal)g", change: viewModel.carbsChange) {
            CarbohydrateChart(data: viewModel.carbsData, days: viewModel.days)
        }
    }
}
```

---

## 🐛 Debugging Guide - When Things Go Wrong

### Common Issues and Solutions

#### Issue: App Crashes on Launch
**Possible Causes:**
- Missing `Secrets.plist` file
- Invalid API key
- Database corruption

**Debugging Steps:**
1. Check console for error messages
2. Verify `Secrets.plist` exists and contains `API_KEY`
3. Test API key validity
4. Clean build folder (Shift+⌘+K)

#### Issue: Charts Not Loading
**Possible Causes:**
- No data in database
- Calculation service error
- UI update issue

**Debugging Steps:**
1. Check if `HomeViewModel` has data
2. Verify `ProgressViewModel` calculations
3. Check console for calculation errors
4. Test with sample data

#### Issue: Food Search Not Working
**Possible Causes:**
- Network connectivity
- API rate limiting
- Invalid API response

**Debugging Steps:**
1. Check internet connection
2. Verify API key is valid
3. Test API endpoint directly
4. Check network logs in console

### Debugging Tools

#### Console Logging
```swift
// Add this to debug data flow
print("🔍 Debug: Loading meals for date: \(date)")
print("📊 Debug: Found \(meals.count) meals")
```

#### SwiftUI Preview
```swift
#Preview {
    HomeView(homeViewModel: MockHomeViewModel())
        .environmentObject(MockNavigationCoordinator())
}
```

#### Breakpoints
- Set breakpoints in ViewModels to trace data flow
- Use conditional breakpoints for specific scenarios
- Check variable values in debugger

---

## �� Testing Strategy - Ensuring Quality

### Unit Testing ViewModels
```swift
class HomeViewModelTests: XCTestCase {
    var viewModel: HomeViewModel!
    var mockRepository: MockNutritionRepository!
    
    override func setUp() {
        mockRepository = MockNutritionRepository()
        viewModel = HomeViewModel(repository: mockRepository)
    }
    
    func testLoadDailyMeals() {
        // Given
        let expectedMeals = [FoodItem(name: "Apple", calories: 95)]
        mockRepository.mockFoodItems = expectedMeals
        
        // When
        viewModel.loadDailyMeals()
        
        // Then
        XCTAssertEqual(viewModel.dailyMeals.count, 1)
        XCTAssertEqual(viewModel.dailyMeals.first?.name, "Apple")
    }
}
```

### UI Testing User Flows
```swift
class MacroTrackerUITests: XCTestCase {
    func testAddFoodFlow() {
        let app = XCUIApplication()
        app.launch()
        
        // Tap add meal button
        app.buttons["Add Meal"].tap()
        
        // Search for food
        let searchField = app.textFields["Search foods..."]
        searchField.tap()
        searchField.typeText("apple")
        
        // Select first result
        app.cells.firstMatch.tap()
        
        // Confirm selection
        app.buttons["Add to Meal"].tap()
        
        // Verify food was added
        XCTAssertTrue(app.staticTexts["Apple"].exists)
    }
}
```

---

## 🔒 Security Considerations - Keeping Data Safe

### API Key Management
- **Never commit API keys** to version control
- Use `Secrets.plist` (already in `.gitignore`)
- Consider using environment variables for CI/CD

### Data Protection
- SwiftData provides encryption by default
- User data stays on device
- No personal information sent to external services

### Input Validation
```swift
// Always validate user input
func validateFoodName(_ name: String) -> Bool {
    return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
}

func validateCalories(_ calories: Int) -> Bool {
    return calories >= 0 && calories <= 10000 // Reasonable range
}
```

---

## 🚀 Performance Optimization Tips

### State Management
- Use `@Published` sparingly
- Combine multiple properties into single state objects
- Use `@StateObject` for long-lived objects
- Use `@ObservedObject` for passed-in objects

### Memory Management
- Use `weak self` in closures to prevent retain cycles
- Dispose of Combine subscriptions
- Clean up resources in `deinit`

### UI Performance
- Use `LazyVStack` for long lists
- Avoid expensive operations in `body`
- Use `@State` for local UI state
- Cache expensive calculations

---

## 📚 Additional Resources

### SwiftUI Documentation
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [SwiftUI Data Flow](https://developer.apple.com/documentation/swiftui/data-flow)

### Combine Framework
- [Combine Documentation](https://developer.apple.com/documentation/combine)
- [Combine Tutorial](https://developer.apple.com/tutorials/combine)

### SwiftData
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [SwiftData Tutorial](https://developer.apple.com/tutorials/swiftdata)

### Architecture Patterns
- [MVVM Pattern](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
- [Repository Pattern](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)

---

## 🤝 Contributing Guidelines

### Code Style
- Follow Swift naming conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### Git Workflow
1. Create feature branch: `git checkout -b feature/new-feature`
2. Make changes and test thoroughly
3. Commit with descriptive messages: `git commit -m "Add dessert meal type"`
4. Push and create pull request
5. Request code review

### Pull Request Checklist
- [ ] Code compiles without warnings
- [ ] All tests pass
- [ ] UI changes tested on different devices
- [ ] Documentation updated if needed
- [ ] No breaking changes to existing APIs

---

## 🔍 Code Review Guidelines - All Reviews Welcome!

### 🎯 Our Code Review Philosophy

**We believe that code reviews are a collaborative learning experience.** Every review, whether you're a seasoned developer or just starting out, brings valuable perspectives that help improve our codebase.

### 📋 What We Look For in Reviews

#### 🏗️ Architecture & Design
- **Does the code follow our MVVM pattern?**
- **Are dependencies properly injected?**
- **Is the separation of concerns maintained?**
- **Does it integrate well with existing components?**

#### 🧪 Code Quality
- **Is the code readable and well-structured?**
- **Are variable and function names descriptive?**
- **Is there appropriate error handling?**
- **Are there any potential memory leaks?**

#### 🎨 UI/UX Considerations
- **Does the UI follow our design patterns?**
- **Is the user experience smooth and intuitive?**
- **Are accessibility features considered?**
- **Does it work well on different screen sizes?**

#### 🚀 Performance & Security
- **Are there any performance bottlenecks?**
- **Is user data handled securely?**
- **Are API calls optimized?**
- **Is memory usage reasonable?**

### 💬 How to Give Constructive Feedback

#### ✅ Positive Feedback Examples
```markdown
Great work! I really like how you:
- Used the existing `IconCell` component instead of creating a new one
- Added proper error handling for the API call
- Included unit tests for the new functionality
- Followed our naming conventions perfectly
```

#### 🔧 Improvement Suggestions
```markdown
Consider these improvements:
- The function is quite long - could we break it into smaller functions?
- We might want to add a loading state while the API call is in progress
- The error message could be more user-friendly
- Have you tested this on different device sizes?
```

#### 🐛 Bug Reports
```markdown
I found a potential issue:
- The app crashes when the network is offline
- The chart doesn't update when new data is added
- The button is not accessible to screen readers
```

### 🤝 How to Request Reviews

#### For New Contributors
```markdown
## Pull Request: Add Dessert Meal Type

### What I Changed
- Added "Dessert" to the MealTypes enum
- Updated IconCell to handle the new meal type
- Added dessert icon to assets

### What I'm Unsure About
- Should dessert have different validation rules?
- Is the icon design consistent with other meal types?
- Do we need to update the onboarding to mention dessert?

### Testing
- [x] Tested on iPhone 14 Pro
- [x] Tested on iPhone SE
- [ ] Need to test on iPad

**Please review and let me know what you think! 🙏**
```

#### For Experienced Contributors
```markdown
## PR: Refactor ProgressViewModel for Better Performance

### Changes
- Consolidated multiple @Published properties into single state object
- Moved heavy calculations to background thread
- Added comprehensive error handling

### Performance Impact
- Reduced UI re-renders by 60%
- Improved chart loading time by 2x
- Memory usage decreased by 15%

### Breaking Changes
- None - all existing APIs maintained

**Ready for review! 🚀**
```

### 🎓 Learning from Reviews

#### For Reviewers
- **Be encouraging**: Start with positive feedback
- **Explain the "why"**: Don't just say "change this," explain why
- **Suggest alternatives**: Offer specific solutions
- **Ask questions**: If something isn't clear, ask!

#### For Authors
- **Don't take it personally**: Reviews are about the code, not you
- **Ask for clarification**: If feedback isn't clear, ask for examples
- **Learn from patterns**: Notice what reviewers consistently point out
- **Thank reviewers**: Acknowledge their time and effort

### 🌟 Review Categories

#### 🆕 New Feature Reviews
- **Functionality**: Does it work as intended?
- **Integration**: Does it fit well with existing features?
- **Testing**: Are edge cases covered?
- **Documentation**: Is the code self-documenting?

#### 🐛 Bug Fix Reviews
- **Root Cause**: Is the real issue being fixed?
- **Regression**: Could this break other features?
- **Testing**: Is the fix verified with tests?
- **Edge Cases**: Are similar issues prevented?

#### 🔧 Refactoring Reviews
- **Improvement**: Is the code actually better?
- **Breaking Changes**: Are existing APIs maintained?
- **Performance**: Are there measurable improvements?
- **Readability**: Is the code easier to understand?

### �� Review Checklist

#### Before Submitting
- [ ] Code compiles without warnings
- [ ] All tests pass
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Commit messages are descriptive

#### During Review
- [ ] Architecture patterns followed
- [ ] Error handling implemented
- [ ] Performance considered
- [ ] Security reviewed
- [ ] Accessibility addressed
- [ ] UI/UX polished

### 🎉 Celebrating Good Reviews

#### Recognition System
- **"Best Reviewer"** - Monthly recognition for helpful reviewers
- **"Quality Contributor"** - For consistently good code
- **"Mentor Award"** - For helping new contributors
- **"Innovation Prize"** - For creative solutions

#### Review Metrics We Track
- **Review Time**: How quickly reviews are completed
- **Review Quality**: Depth and helpfulness of feedback
- **Collaboration**: How well reviewers and authors work together
- **Learning**: How much contributors improve over time

### 🚀 Getting Started with Reviews

#### For New Reviewers
1. **Start Small**: Review simple UI changes first
2. **Use Templates**: Follow our review templates
3. **Ask Questions**: Don't hesitate to ask for clarification
4. **Be Patient**: Learning takes time

#### For Experienced Reviewers
1. **Mentor Others**: Help new contributors learn
2. **Share Knowledge**: Explain architectural decisions
3. **Set Standards**: Maintain code quality
4. **Lead by Example**: Show best practices

### �� Review Templates

#### Quick Review Template
```markdown
## Quick Review ✅

**Overall**: Looks good! Minor suggestions below.

**Suggestions**:
- [ ] Consider adding a loading state
- [ ] Maybe add error handling for edge case

**Questions**:
- Have you tested this on different devices?

**Approval**: ✅ Ready to merge with minor changes
```

#### Detailed Review Template
```markdown
## Detailed Review ��

**Architecture**: ✅ Follows MVVM pattern well
**Performance**: ⚠️ Consider caching for repeated API calls
**Security**: ✅ Input validation looks good
**Testing**: ❌ Missing unit tests for new functionality

**Specific Issues**:
1. Line 45: Potential memory leak in closure
2. Line 78: Magic number should be a constant
3. Line 120: Missing error handling

**Suggestions**:
- Extract the API call logic into a separate service
- Add accessibility labels for screen readers
- Consider using Combine for better error handling

**Questions**:
- How does this handle offline scenarios?
- Have you tested the performance with large datasets?

**Next Steps**:
- [ ] Add unit tests
- [ ] Fix memory leak
- [ ] Add accessibility support
- [ ] Performance testing

**Approval**: ⏳ Needs changes before merge
```

### 🌍 Community Guidelines

#### Respect & Inclusion
- **Be respectful**: Everyone's contribution is valuable
- **Be inclusive**: Welcome developers of all experience levels
- **Be patient**: Learning takes time and practice
- **Be helpful**: Offer guidance and support

#### Communication
- **Use clear language**: Avoid jargon when possible
- **Provide context**: Explain why changes are suggested
- **Be specific**: Point to exact lines or functions
- **Be constructive**: Focus on improvement, not criticism

#### Collaboration
- **Work together**: Reviews are a team effort
- **Share knowledge**: Help others learn and grow
- **Celebrate success**: Acknowledge good work
- **Learn continuously**: Stay open to new ideas

---

## 🎉 You're Ready to Contribute!

You now have a solid understanding of the MacroTracker codebase. Here's what you can do next:

1. **Explore the code**: Start with `MacroTrackerApp.swift` and follow the flow
2. **Run the app**: Build and test on simulator/device
3. **Pick a small feature**: Add a new UI component or fix a bug
4. **Ask questions**: Don't hesitate to ask for clarification
5. **Share improvements**: Suggest better patterns or optimizations
6. **Review code**: Help others by reviewing their contributions
7. **Learn and grow**: Every review is a learning opportunity

Remember: Every great app started with a single line of code. Your contributions help make MacroTracker better for everyone! 🚀

---

*Happy coding! If you have questions, feel free to ask. The codebase is designed to be welcoming to new developers, and all code reviews are welcome! 🌟*