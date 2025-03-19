//
//  APIClient.swift
//  MacroTracker
//
//  Created by Gorkem on 17.03.2025.
//

import Combine
import Foundation

protocol APIClientInterface {
    associatedtype EndpointType: APIEndpoint
    func request<T: Decodable>(_ endpoint: EndpointType) -> AnyPublisher<T, Error>
}


class APIClient<EndpointType: APIEndpoint>: APIClientInterface {
    func request<T>(_ endpoint: EndpointType) -> AnyPublisher<T, Error> where T : Decodable {
        var urlRequest = URLRequest(url: endpoint.url!)
                urlRequest.httpMethod = endpoint.method.rawValue
                if let headers = endpoint.headers {
                    for (key, value) in headers {
                        urlRequest.addValue(value, forHTTPHeaderField: key)
                        print(urlRequest.allHTTPHeaderFields)
                    }
                }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap { data, response -> Data in
                print("Data: ", String(data: data, encoding: .utf8)!)
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else { throw APIError.invalidResponse}

                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
