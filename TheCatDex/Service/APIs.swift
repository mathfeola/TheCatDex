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
    func execute(using session: URLSession) async throws -> Any
}

enum FetchError: Error {
    case decodingError(Error)
    case networkError(Error)
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
    
    private func fetchData<T: Codable & Equatable>(from request: URLRequest, session: URLSession) async throws -> T {
        let (data, _) = try await session.data(for: request)
        
        if T.self == String.self, let stringData = String(data: data, encoding: .utf8) as? T {
            return stringData
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw FetchError.decodingError(error)
        }
    }

    func genericFetch<T: Codable & Equatable>(parameters: [URLQueryItem]?, using session: URLSession = URLSession.shared) async throws -> [T] {
        do {
            return try await fetchData(from: composeRequest(queryItems: parameters), session: session)
        } catch let error as FetchError {
            throw error
        } catch {
            throw FetchError.networkError(error)
        }
    }
    
    func makeParameters(_ parameters: [(name: String, value: String)]) -> [URLQueryItem] {
        parameters.map { name, value in
            return URLQueryItem(name: name, value: value)
        }
    }
}
