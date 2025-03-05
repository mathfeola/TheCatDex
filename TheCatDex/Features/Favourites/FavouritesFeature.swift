//
//  FavouritesFeature.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import ComposableArchitecture

struct FavouritesFeature: Reducer {
    
    enum ErrorMessages: String {
        case fetchingFromDatabase = "❌ Error fetching breeds from SwiftData:"
    }
    
    struct State: Equatable {
        var favouritesBreeds: [CatBreed] = []
        var selectedBreed: BreedDetailFeature.State?
        var shouldOpenDetail = false
    }
    
    enum Action: Equatable {
        case fetchFavourites
        case breedSelected(CatBreed)
        case closeDetailModal
    }
    
    func fetchFavouriteCatBreedsFromDatabase() -> [CatBreed] {
        @Dependency(\.catBreedDatabase.fetchAll) var fetchAll
        do {
            return try fetchAll()
        } catch {
            print("\(ErrorMessages.fetchingFromDatabase) \(error)")
            return []
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchFavourites:
                state.favouritesBreeds = fetchFavouriteCatBreedsFromDatabase()
                return .none
            case let .breedSelected(breed):
                state.selectedBreed = BreedDetailFeature.State(breed: breed)
                state.shouldOpenDetail = true
                return .none
            case .closeDetailModal:
                state.shouldOpenDetail = false
                return .none
            }
        }
    }
}
