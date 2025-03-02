//
//  CatAPI.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import Foundation

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
    
    func execute() async throws -> Any {
        switch self {
        case .fetchCatBreeds(let page):
            let parameters = makeParameters([(name: "page", value: "\(page)")])
            return try await genericFetch(parameters: parameters) as [CatBreed]
        }
    }
    
    struct Failure: Error {}
}
