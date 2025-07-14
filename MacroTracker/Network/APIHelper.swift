//
//  APIHelper.swift
//  MacroTracker
//
//  Created by Gorkem on 17.03.2025.
//

import Foundation

protocol APIEndpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
    var url: URL? {get}
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum APIError: Error {
    case invalidResponse
    case invalidData
}

struct APIKeyProvider {
    static var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let nsDictionary = NSDictionary(contentsOfFile: path),
              let key = nsDictionary["API_KEY"] as? String else {
            fatalError("API Key not found. Make sure Secrets.plist is in the project and contains the API_KEY.")
        }
        return key
    }
}
