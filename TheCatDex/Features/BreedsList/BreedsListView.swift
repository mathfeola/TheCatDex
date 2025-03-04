//
//  BreedsListView.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import SwiftUI
import ComposableArchitecture

struct BreedsListView: View {
    let navigationBarTitle = "Cat breeds"
    let emptyListSymbolName = "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90"
    let store: StoreOf<BreedListFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                TextField("Search breeds...", text: viewStore.binding(
                    get: \.filterText,
                    send: { .filter($0) }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                if !viewStore.filterText.isEmpty {
                    filteredBreedsList
                } else {
                    catBreedList
                }
                
                if viewStore.isFetchingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                                .foregroundStyle(Color("lightCoral"))
                                .padding()
                            Spacer()
                        }
                    }
            }
            .task {
                if viewStore.breeds.isEmpty {
                    viewStore.send(.fetchBreedList)
                }
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
                breedDetailSheet
            }
        }
    }
    
    private var breedDetailSheet: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if let selectedBreedState = viewStore.selectedBreed {
                BreedDetailSheet(store: Store(
                    initialState: BreedDetailFeature.State(breed: selectedBreedState.breed),
                    reducer: { BreedDetailFeature() }
                ))
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Image(systemName: "cat.fill")
                .resizable()
                .frame(width: 140, height: 100)
                .padding()
            Text("No catties match your search 🙀")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
        }
    }
    
    private var errorStateView: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.shouldShowErrorState {
                VStack {
                    Image(systemName: emptyListSymbolName)
                        .resizable()
                        .foregroundStyle(.pink)
                        .frame(width: 160, height: 120)
                        .padding()
                    Text(viewStore.currentErrorMessage)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.pink)
                        .padding()
                }
            }
        }
    }
    
    private var catBreedList: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List(viewStore.breeds, id: \.id) { breed in
                CatBreedItemList(breed: breed, isFavourite: viewStore.favouriteBreedIDs.contains(breed.id))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        viewStore.send(.breedSelected(breed))
                    }
                    .onAppear {
                        if breed == viewStore.breeds.last {
                            viewStore.send(.fetchMoreBreeds)
                        }
                    }
            }
            .overlay {
                errorStateView
            }
            .navigationBarTitle(navigationBarTitle)
        }
    }
    
    private var filteredBreedsList: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List(viewStore.filteredBreeds, id: \.id) { breed in
                CatBreedItemList(breed: breed, isFavourite: viewStore.favouriteBreedIDs.contains(breed.id))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        viewStore.send(.breedSelected(breed))
                    }
                    .onAppear {
                        if breed == viewStore.breeds.last {
                            viewStore.send(.fetchMoreBreeds)
                        }
                    }
            }
            .overlay {
                if viewStore.filteredBreeds.isEmpty && !viewStore.filterText.isEmpty {
                    emptyStateView
                }
            }
            .overlay {
                errorStateView
            }
            .navigationBarTitle(navigationBarTitle)
        }
    }
}
