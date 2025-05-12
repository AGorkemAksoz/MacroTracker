//
//  HomeView.swift
//  MacroTracker
//
//  Created by Gorkem on 17.03.2025.
//

import WebKit
import SwiftUI

struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel(nutritionService: NutritionService())
    @State private var typedMeal: String = "Chicken Breast"
    var body: some View {
        
        VStack {
            TextField("Type Your Meal", text: $typedMeal)
                .padding()
                .border(.blue, width: 2)
                .frame(height: UIScreen.main.bounds.height * 0.2)
                .onSubmit {
                    homeViewModel.fetchNutrition(for: typedMeal)
            }
            
//            FoodNutritionView(foods: $homeViewModel.nutrition)
            
            GIFWebView(url: URL(string: "https://ucarecdn.com/05fcc879-04d4-4222-8896-e3772a8a3060/KCBKjma.gif")!)
                .frame(width: 300, height: 300)
                .cornerRadius(10)
            Spacer()
        }
        .onAppear {
            let request = NSMutableURLRequest(url: URL(string: "https://exercisedb-api.vercel.app/api/v1/muscles/chest/exercises?offset=10&limit=10")!,
                                                    cachePolicy: .useProtocolCachePolicy,
                                                timeoutInterval: 10.0)
            request.httpMethod = "GET"

            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
              if (error != nil) {
                print(error as Any)
              } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
                  print(String(data: data!, encoding: .utf8))
              }
            })

            dataTask.resume()
        }
    }
}

#Preview {
    HomeView()
}


struct FoodNutritionView: View {
    @Binding var foods: [Item]
    var body: some View {
        List(foods, id: \.name) { food in
            VStack(alignment: .leading, spacing: 8) {
                Text(food.name ?? "Unknown Food")
                    .font(.title2)
                
                FoodNutritionCellView(nutrition: "Serving Size(gr)", value: String(food.servingSizeG!))
                FoodNutritionCellView(nutrition: "Calories", value: String(food.calories!))
                FoodNutritionCellView(nutrition: "Protein", value: String(food.proteinG!))
                
                
            }
        }
    }
}

struct FoodNutritionCellView: View {
    let nutrition: String
    let value: String
    var body: some View {
        HStack(spacing: 8) {
            Text(nutrition)
            
            Text(value)
        }
    }
}


struct GIFWebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        webView.scrollView.isScrollEnabled = false // Scroll'u kapat
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
}
