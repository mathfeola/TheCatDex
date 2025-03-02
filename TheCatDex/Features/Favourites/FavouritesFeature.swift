//
//  FavouritesFeature.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import SwiftUI
import ComposableArchitecture

struct FavouritesFeature: Reducer {
    struct State: Equatable {
        var someInitialText = "someInitialText"
    }
    
    enum Action: Equatable {
        case someAction
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .someAction:
                state.someInitialText = "someInitialText"
                return .none
            }
        }
    }
}

struct FavouritesView: View {
    let store: StoreOf<FavouritesFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Text(viewStore.someInitialText)
        }
    }
}
