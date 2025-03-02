//
//  BreedListFeature.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct BreedListFeature {
    
    @ObservableState
    struct State {
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
                print("Load list")
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
        Text("CatBreeds")
    }
}
