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
        var breeds: [CatBreed]?
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
            Text("CatBreeds")
        }
    }
}
