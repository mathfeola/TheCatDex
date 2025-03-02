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
    }
    
    enum Action {
        case breedItemTapped
        case filter(String)
        case breedListResponse([CatBreed])
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .breedListResponse(breeds):
                state.breeds = breeds
                return .none
            case .breedItemTapped:
                print("Open detail View")
                return .none
            case .filter(_):
                print("Filter")
                return .none
            }
        }
    }
}

struct BreedsListView: View {
    let store: StoreOf<BreedListFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Text("CatBreeds")
                    List(viewStore.breeds, id: \.id) { breed in
                        HStack {
                            
                            if let breedImage = breed.image,
                               let url = URL(string: breedImage.url) {
                                AsyncImage(url: url) { image in
                                    image
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                } placeholder: {
                                    Image(systemName: "cat.circle")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                }
                            }
                            Text("CatBreed: \(breed.name ?? "Cat name")")
                        }
                    }
            }.onAppear {
                Task {
                    do {
                        let breeds = try await CatAPI.fetchCatBreeds(page: 0).execute() as? [CatBreed]
                        viewStore.send(.breedListResponse(breeds ?? []))
                    } catch {
                        print("Not worked")
                    }
                }
            }
        }
    }
}
