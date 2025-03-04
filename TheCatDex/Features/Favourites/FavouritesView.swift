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
                }
            }
        }
    }
    
    private var emptyListView: some View {
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
}
