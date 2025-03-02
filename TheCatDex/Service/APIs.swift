//
//  APIs.swift
//  TheCatDex
//
//  Created by Matheus Feola on 01/03/2025.
//

import Foundation

protocol API {
    var baseURL: String { get }
    var version: String { get }
    var key: String { get }
    var httpMethod: String { get }
    var path: String { get }
    
    func execute() async throws -> Any
}

extension API {
    private func composeURL(queryItems: [URLQueryItem]) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = baseURL
        components.path = "/\(version)/\(path)"
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components.url else { fatalError("Invalid URL") }
        return url
    }

    private func composeRequest(queryItems: [URLQueryItem]?) -> URLRequest {
        var request = URLRequest(url: composeURL(queryItems: queryItems ?? []))
        request.httpMethod = httpMethod
        request.setValue(key, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    private func fetchData<T: Codable & Equatable>(from url: URL) async throws -> T {
        let (data, _) = try await URLSession.shared.data(from: url)

        if T.self == String.self, let stringData = String(data: data, encoding: .utf8) as? T {
            return stringData
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func genericFetch<T: Codable & Equatable>(parameters: [URLQueryItem]?) async throws -> [T] {
        do {
            let request = composeRequest(queryItems: parameters)
            if let url = request.url {
                let decodedResponse: [T] = try await fetchData(from: url)
                return decodedResponse
            } else {
                return []
            }
        } catch {
            print("Request failed:", error.localizedDescription)
            return []
        }
    }
    
    func makeParameters(_ parameters: [(name: String, value: String)]) -> [URLQueryItem] {
        parameters.map { name, value in
            return URLQueryItem(name: name, value: value)
        }
    }
}
