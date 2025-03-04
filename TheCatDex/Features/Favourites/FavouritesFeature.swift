//
//  FavouritesFeature.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

struct FavouritesFeature: Reducer {
    struct State: Equatable {
        var favouritesBreeds: [CatBreed] = []
        var selectedBreed: BreedDetailFeature.State?
        var shouldOpenDetail = false
    }
    
    enum Action: Equatable {
        case fetchFavouriteCatBreeds
        case favouriteCatBreedsResponse([CatBreed])
        case breedSelected(CatBreed)
        case closeDetailModal
        case newOfflineFetchFavouriteCatBreeds([CatBreed])
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchFavouriteCatBreeds:
                return .none
            case let .favouriteCatBreedsResponse(breeds):
                state.favouritesBreeds = breeds
                return .none
            case let .breedSelected(breed):
                state.selectedBreed = BreedDetailFeature.State(breed: breed)
                state.shouldOpenDetail = true
                return .none
            case .closeDetailModal:
                state.shouldOpenDetail = false
                return .none
            case let .newOfflineFetchFavouriteCatBreeds(breeds):
                state.favouritesBreeds = breeds
                return .none
            }
        }
    }
}

struct FavouritesView: View {
    let store: StoreOf<FavouritesFeature>
    @Environment(\.modelContext) var modelContext
    @Query var currentFavouritesBreeds: [CatBreed]
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List(viewStore.favouritesBreeds, id: \.id) { breed in
                    FavoriteItem(breed: breed)
                        .onTapGesture {
                            viewStore.send(.breedSelected(breed))
                        }
                }
                .overlay {
                    emptyListView
                }
                .navigationBarTitle("Favourite cat breeds ⭐️")
            }
            .task {
                viewStore.send(.newOfflineFetchFavouriteCatBreeds(currentFavouritesBreeds))
            }
            .sheet(
                isPresented: Binding(
                    get: { viewStore.shouldOpenDetail },
                    set: { isPresented in
                        if !isPresented {
                            viewStore.send(.closeDetailModal)
                        }
                    }
                )
            ) {
                if let selectedBreedState = viewStore.selectedBreed {
                    BreedDetailSheet(store: Store(
                        initialState: BreedDetailFeature.State(breed: selectedBreedState.breed),
                        reducer: { BreedDetailFeature() }
                    ))
                }
            }
        }
    }
    
    var emptyListView: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.favouritesBreeds.isEmpty {
                VStack {
                    Image(systemName: "cat.fill")
                        .resizable()
                        .frame(width: 140, height: 100)
                        .padding()
                    Text("You got no favourite cat breeds yet! 😿")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                }
            }
        }
    }
    
    func unfavorite() {
        do {
            try modelContext.delete(model: CatBreed.self)
        } catch {
            print("Failed to clear all Country and City data.")
        }
    }
}

struct FavoriteItem: View {
    let breed: CatBreed
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(breed.name ?? "No breed name")
                .font(.title)
            lifeSpan
        }
    }
    
    var lifeSpan: Text {
        var result = AttributedString(breed.lifeSpan)
        result.font = .callout
        result.foregroundColor = .lightCoral
        return Text("Life span: \(result)")
    }
}
