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
            let parameters = makeParameters([
                (name: "limit", value: "\(20)"),
                (name: "page", value: "\(page)")
            ])
            return try await genericFetch(parameters: parameters) as [CatBreed]
        }
    }
    
    func mock() -> [CatBreed] {
        return [
            
            CatBreed(id: "abys",
                     name: "tudo igual",
                     origin: "Egypt",
                     temperament: "Active, Energetic, Independent, Intelligent, Gentle",
                     description: "The Abyssinian is easy to care for, and a joy to have in your home. They’re affectionate cats and love both people and other animals.",
                     image: CatImage(id: "0XYvRd7oD",
                                     width: 1204,
                                     height: 1445,
                                     url: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg"),
                     isFavourite: false),
            
            CatBreed(id: "aege",
                     name: "Aegean",
                     origin: "Greece",
                     temperament: "Affectionate, Social, Intelligent, Playful, Active",
                     description: "Native to the Greek islands known as the Cyclades in the Aegean Sea, these are natural cats, meaning they developed without humans getting involved in their breeding. As a breed, Aegean Cats are rare, although they are numerous on their home islands. They are generally friendly toward people and can be excellent cats for families with children.",
                     image: CatImage(id: "ozEvzdVM-",
                                     width: 1200,
                                     height: 800,
                                     url: "https://cdn2.thecatapi.com/images/ozEvzdVM-.jpg"),
                     isFavourite: false)
        ]
    }
    
    struct Failure: Error {}
}
