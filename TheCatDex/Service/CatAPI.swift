//
//  CatAPI.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import Foundation
import ComposableArchitecture

public protocol CatBreedService {
    func fetchCatBreeds(_ page: Int) async throws -> [CatBreed]
}

public struct CatAPIService: CatBreedService {
    public init() {}

    public func fetchCatBreeds(_ page: Int) async throws -> [CatBreed] {
        let api = CatAPI.fetchCatBreeds(page: page)
        guard let breeds = try await api.execute() as? [CatBreed] else {
            throw FetchError.decodingError(NSError(domain: "Invalid data", code: -1))
        }
        return breeds
    }
}

extension DependencyValues {
    var catBreedService: CatBreedService {
        get { self[CatBreedServiceKey.self] }
        set { self[CatBreedServiceKey.self] = newValue }
    }
}

private struct CatBreedServiceKey: DependencyKey {
    static let liveValue: CatBreedService = CatAPIService()
}

enum CatAPI: API {
    case fetchCatBreeds(page: Int)
    
    var baseURL: String {
        guard let catApiBaseUrl = EnvironmentUtil().catApiBaseUrl else {
            fatalError("Invalid base URL on project configuration 🫨💣")
        }
        return catApiBaseUrl
    }
    
    var version: String {
        guard let catApiVersion = EnvironmentUtil().catApiBaseUrlVersion else {
            fatalError("Invalid API version on project configuration 🫨💣")
        }
        return catApiVersion
    }
    
    var key: String {
        guard let catApiKey = EnvironmentUtil().catApiKey else {
            fatalError("Invalid API key on project configuration 🫨💣")
        }
        return catApiKey
    }
    
    var httpMethod: String {
        switch self {
        case .fetchCatBreeds:
            "GET"
        }
    }
    
    var path: String {
        switch self {
        case .fetchCatBreeds:
            "breeds"
        }
    }
    
    func execute(using session: URLSession = URLSession.shared) async throws -> Any {
        switch self {
        case .fetchCatBreeds(let page):
            let parameters = makeParameters([
                (name: "limit", value: "\(20)"),
                (name: "page", value: "\(page)")
            ])
            return try await genericFetch(parameters: parameters, using: session) as [CatBreed]
        }
    }
}
