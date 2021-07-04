//
//  APIService.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/3/21.
//

import Foundation
import Combine

protocol APIServiceProtocol {
    func get<T: Codable>(url: String) -> AnyPublisher<T, Error>
}

class APIService: APIServiceProtocol {
    static let shared: APIServiceProtocol = APIService()
    
    func get<T: Codable>(url: String) -> AnyPublisher<T, Error> {
        let urlRequest = APIHelper.request(url, params: ["page": "1"])
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                          throw URLError(.badServerResponse)
                      }
                return element.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

class APIHelper {
    static let defaultHeader: [String: String] = [
        "Content-Type": "application/json; charset=utf-8"
        
    ]
    static func request(_ path: String, params: [String: String] = [:], headers: [String: String] = defaultHeader) -> URLRequest {
        var urlString = "\(baseURL)/\(path)"
        if !params.isEmpty {
            let queries = params.map { (key, value) in
                return "\(key)=\(value)"
            }.joined(separator: "&").appending("&api_key=\(APIKey)")
            urlString = "\(urlString)?\(queries)"
        }
        
        var request = URLRequest(url: URL(string: urlString)!)
        
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        return request
    }
}
