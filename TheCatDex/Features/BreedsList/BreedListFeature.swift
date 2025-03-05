//
//  BreedListFeature.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import SwiftUI
import ComposableArchitecture

struct BreedListFeature: Reducer {
    enum FeatureErrorMessages: String {
        case decodingError = "🐛 Decoding error: "
        case networkError = "🌐 Network error: "
        case unknownError = "❌ Unknown error: "
    }
    
    struct State: Equatable {
        var breeds: [CatBreed] = []
        var selectedBreed: BreedDetailFeature.State?
        var shouldOpenDetail = false
        var shouldShowErrorState = false
        var currentErrorMessage = String()
        var currentPage = 0
        var isFetchingMore = false
        var favouriteBreedIDs: Set<String> = []
        var filterText: String = ""
        var filteredBreeds: [CatBreed] = []
    }
    
    enum Action: Equatable {
        case fetchBreedList
        case breedListResponse([CatBreed])
        case filter(String)
        case breedSelected(CatBreed)
        case closeDetailModal
        case displayError(String)
        case fetchMoreBreeds
        case fetchCurrentFavourites
    }
    
    func fetchCatBreedsFromApi(page: Int) async throws -> [CatBreed] {
        @Dependency(\.catBreedService) var catBreedService
        return try await catBreedService.fetchCatBreeds(page)
    }

    func fetchFavouriteCatBreedsFromDatabase() -> [CatBreed] {
        @Dependency(\.catBreedDatabase.fetchAll) var fetchAll
        do {
            return try fetchAll()
        } catch {
            return []
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchBreedList:
                state.currentPage = 0
                state.isFetchingMore = true
                state.favouriteBreedIDs = Set(fetchFavouriteCatBreedsFromDatabase().map { $0.id })
                return .run { send in
                    do {
                        let breeds = try await fetchCatBreedsFromApi(page: 0)
                        await send(.breedListResponse(breeds))
                    } catch FetchError.decodingError(let decodingError) {
                        await send(.displayError(FeatureErrorMessages.decodingError.rawValue + decodingError.localizedDescription))
                    } catch FetchError.networkError(let networkError) {
                        await send(.displayError(FeatureErrorMessages.networkError.rawValue + networkError.localizedDescription))
                    } catch {
                        await send(.displayError(FeatureErrorMessages.unknownError.rawValue + error.localizedDescription))
                    }
                }
            case let .breedListResponse(breeds):
                state.breeds += breeds
                state.currentPage += 1
                state.isFetchingMore = false
                state.currentErrorMessage = String()
                state.shouldShowErrorState = false
                return .none
            case let .filter(query):
                state.filterText = query
                if query.isEmpty {
                    state.filteredBreeds = state.breeds
                } else {
                    state.filteredBreeds = state.breeds.filter { breed in
                        if let breedName = breed.name {
                            return breedName.lowercased().contains(query.lowercased())
                        }
                        return false
                    }
                }
                return .none
            case let .breedSelected(breed):
                state.selectedBreed = BreedDetailFeature.State(breed: breed)
                state.shouldOpenDetail = true
                return .none
            case .closeDetailModal:
                state.shouldOpenDetail = false
                return .none
            case let .displayError(message):
                state.currentErrorMessage = message
                state.shouldShowErrorState = true
                return .none
            case .fetchMoreBreeds:
                guard !state.isFetchingMore else { return .none }
                state.isFetchingMore = true
                return .run { [currentPage = state.currentPage] send in
                    let moreBreeds = try await fetchCatBreedsFromApi(page: currentPage)
                    await send(.breedListResponse(moreBreeds))
                }
            case .fetchCurrentFavourites:
                state.favouriteBreedIDs = Set(fetchFavouriteCatBreedsFromDatabase().map { $0.id })
                return .none
            }
        }
    }
}
