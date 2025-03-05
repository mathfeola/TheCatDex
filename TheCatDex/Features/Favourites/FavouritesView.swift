//
//  FavouritesView.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import SwiftUI
import ComposableArchitecture

struct FavouritesView: View {
    let store: StoreOf<FavouritesFeature>
    let navigationBarTitle = "Favourite cat breeds ⭐️"
    
    enum Messages: String {
        case emptyList = "You got no favourite cat breeds yet! 😿"
    }
    
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
                .navigationBarTitle(navigationBarTitle)
            }
            .task {
                viewStore.send(.fetchFavourites)
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
                    .onDisappear {
                        viewStore.send(.fetchFavourites)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var emptyListView: some View {
        let emptyFavouritListSymbol = "cat.fill"
        let emptyMessage = Messages.emptyList
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.favouritesBreeds.isEmpty {
                VStack {
                    Image(systemName: emptyFavouritListSymbol)
                        .resizable()
                        .frame(width: 140, height: 100)
                        .padding()
                    Text(emptyMessage.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                }
            }
        }
    }
}
