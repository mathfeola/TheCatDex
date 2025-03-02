//
//  BreedListFeature.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import SwiftUI
import ComposableArchitecture

struct BreedListFeature: Reducer {
    
    struct State: Equatable {
        var breeds: [CatBreed] = []
        var isLoading = false
        var selectedBreed: BreedDetailFeature.State?
        var shouldOpenDetail = false
    }
    
    enum Action {
        case fetchBreedList
        case breedListResponse([CatBreed])
        case filter(String)
        case breedSelected(CatBreed)
        case closeDetailModal
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchBreedList:
                return .run { send in
                    do {
                        let breeds = try await CatAPI.fetchCatBreeds(page: 0).execute() as? [CatBreed]
                        await send(.breedListResponse(breeds ?? []))
                    } catch {
                        print("Not worked")
                    }
                }
            case let .breedListResponse(breeds):
                state.breeds = breeds
                return .none
            case .filter(_):
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

struct BreedsListView: View {
    let store: StoreOf<BreedListFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List(viewStore.breeds, id: \.id) { breed in
                    CatBreedItemList(breed: breed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewStore.send(.breedSelected(breed))
                        }
                }
                .navigationBarTitle("CatBreeds")
            }
            .task {
                viewStore.send(.fetchBreedList)
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
                    BreedDetailView(store: Store(
                        initialState: BreedDetailFeature.State(breed: selectedBreedState.breed),
                        reducer: { BreedDetailFeature() }
                    ))
                }
            }
        }
    }
}

struct CatBreedItemList: View {
    let breed: CatBreed
    
    var body: some View {
        HStack {
            if let breedImage = breed.image,
               let url = URL(string: breedImage.url) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.pink, lineWidth: 2)
                            )
                    case .failure:
                        Image(systemName: "cat.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                    case .empty:
                        ProgressView()
                            .frame(width: 40, height: 40)
                    @unknown default:
                        fatalError("sssss")
                    }
                }
            }
            Text("\(breed.name ?? "Cat name")")
            Spacer()
        }
    }
}
