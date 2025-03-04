//
//  FavouritesFeature.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import ComposableArchitecture

struct FavouritesFeature: Reducer {
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
    
    func fetchCatBreeds() -> [CatBreed] {
        @Dependency(\.catBreedDatabase.fetchAll) var fetchAll
        do {
            return try fetchAll()
        } catch {
            print("❌ Error fetching breeds from SwiftData: \(error)")
            return []
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchFavourites:
                state.favouritesBreeds = fetchCatBreeds()
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
