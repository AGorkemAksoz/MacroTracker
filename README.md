## MacroTracker

MacroTracker is a SwiftUI iOS app for tracking daily nutrition and macros (calories, protein, carbs, fat) across your meals.

---

## Features

- **Meal-based tracking**
  - Log foods into breakfast, lunch, dinner, and snack
  - View daily meal breakdowns and totals
- **Macro & calorie insights**
  - See total calories and macro distribution per day
  - Quick cards and summaries for calories and macros
- **Progress & charts**
  - Weekly/monthly progress views
  - Charts for calories and macros over time
- **Fast food search**
  - Search foods via a remote nutrition database
  - Add multiple items at once and confirm before saving
- **Onboarding experience**
  - Simple multi-screen onboarding for first-time users
- **Offline-friendly**
  - Saved foods and meals are stored locally, so your history is available without a network

For a deep-dive into the internals, see `ARCHITECTURE_DOCUMENTATION.md`.

---

## Architecture Overview

- **Pattern: MVVM + Repository**
  - **View**: SwiftUI screens under `Views/` (e.g. `HomeView`, `ChartsView`, onboarding, search/entering food, detail screens).
  - **ViewModel**: View models under `Views/**/ViewModel/` manage business logic and state (`HomeViewModel`, `ProgressViewModel`, etc.).
  - **Model**: Data entities in `Entities/` (e.g. `FoodItem`, `Nutrition`) plus SwiftData storage in `Database/`.
- **Services & business logic**
  - `Service/` contains use-case oriented services like `NutritionRepository`, `NutritionService`, `ProgressDataService`, `ProgressCalculationService`, `OnboardingManager`.
  - `NutritionRepository` implements the Repository pattern, coordinating between local database, network service, and cache.
- **Dependency injection**
  - `DependencyContainer` wires together services and repositories and exposes factory methods for view models.
  - The app entry (`MacroTrackerApp.swift`) creates a `ModelContainer` (SwiftData) and a `DependencyContainer`, then injects them into the UI.
- **Navigation**
  - `NavigationCoordinator` + `NavigationRoute` coordinate navigation using `NavigationStack` and typed routes (e.g. meal detail, food detail, search, confirm).

More architectural detail, examples, and diagrams are available in `ARCHITECTURE_DOCUMENTATION.md`.

---

## Network Layer

- **API client**
  - The generic `APIClient` wraps `URLSession` and `Combine` to perform typed requests: `request<T: Decodable>(_ endpoint: EndpointType) -> AnyPublisher<T, Error>`.
  - It centralizes request creation, headers, response validation, decoding, and background scheduling.
- **Endpoints**
  - `NutritionEndpoint` describes the nutrition search API:
    - Base URL: `https://api.calorieninjas.com`
    - Path: `/v1/nutrition`
    - Method: `GET`
    - Headers: `X-Api-Key: <your-api-key>`
    - Query parameter: `query` (free-text food description, e.g. `"1 apple"`).
- **Repository integration**
  - `NutritionRepository` calls the network layer via `NutritionService` to search for foods, then maps responses into app models.
  - Results can be cached via `NutritionCacheService` and saved locally via `NutritionDatabaseService`.
- **API key management**
  - API keys are loaded from `Secrets.plist` and are not committed to source control.
  - For a detailed, step-by-step setup, see `API_SETUP.md`.

---

## How to Build & Run

- **Requirements**
  - Xcode 15 or later
  - iOS 17+ simulator or device
  - A CalorieNinjas API key (free tier is enough)

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/MacroTracker.git
cd MacroTracker
```

### 2. Configure the API key (`Secrets.plist`)

1. Open the project in Xcode (`MacroTracker.xcodeproj`).
2. In the MacroTracker target, create a new file:
   - File → New → File… → Resource → Property List.
   - Name it exactly `Secrets.plist`.
3. Add a key `API_KEY` of type `String` and paste your CalorieNinjas API key as the value.
4. Ensure `Secrets.plist` is added to the app target and is **not** committed (it is ignored via `.gitignore`).

You can find a more detailed guide (including a sample plist) in `API_SETUP.md`.

### 3. Build & run

1. Select the `MacroTracker` scheme.
2. Choose an iOS simulator (e.g. iPhone 15).
3. Build (`⌘ + B`) and run (`⌘ + R`).
4. On first launch, you will see the onboarding flow, then the main tab view with Home and Charts.

---

## Contributing

Contributions are welcome – from small UI tweaks and bug fixes to new features.

- **Getting started**
  - Read `ARCHITECTURE_DOCUMENTATION.md` to understand the structure (MVVM, Repository, DI, navigation, etc.).
  - Set up your environment and API key as described above.
- **Workflow**
  - **Fork** the repo (or create a feature branch if you have write access).
  - Create a branch: `git checkout -b feature/<short-description>`.
  - Make your changes and add/update tests where appropriate.
  - Run the app and verify core flows (meal logging, search, charts).
  - Open a Pull Request with a clear description of:
    - What you changed
    - Any UI/UX impact
    - How to test the change
- **Code style & guidelines**
  - Follow standard Swift and SwiftUI conventions.
  - Keep view models focused on state and business logic; avoid networking or persistence code in views.
  - Prefer dependency injection over creating services directly.
  - Keep functions small and focused; add comments for non-obvious logic.

For more detailed guidance (including review checklists and testing examples), see the **Contributing Guidelines** section at the end of `ARCHITECTURE_DOCUMENTATION.md`.

---

## License

This project is available under the terms of the `LICENSE` file in this repository.
