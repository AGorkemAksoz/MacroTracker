//
//  NutritionEndpoint.swift
//  MacroTracker
//
//  Created by Gorkem on 17.03.2025.
//

import Foundation

enum NutritionEndpoint: APIEndpoint {
    case getNutrition(query: String)

    var baseURL: URL {
        return URL(string: "https://api.calorieninjas.com")!
    }

    var path: String {
        return "/v1/nutrition"
    }

    var method: HTTPMethod {
        return .get
    }

    var headers: [String: String]? {
        return ["X-Api-Key": "lQBvfQTHIRJji0NR2oYVuA==D2WRZjgXYvg5ZJt9"] // API Key başlık içinde olmalı
    }

    var parameters: [String: Any]? {
        return nil // Parametreler URL query parametresi olarak eklenecek
    }

    var url: URL? {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        
        switch self {
        case .getNutrition(let query):
            let encodedQuery = query
            components.queryItems = [URLQueryItem(name: "query", value: encodedQuery)]
        }
        
        return components.url
    }
}

