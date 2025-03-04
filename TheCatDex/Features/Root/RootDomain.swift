//
//  RootDomain.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        TabView {
            BreedsListView(store: store.scope(state: \.tab1, action: \.tab1))
                .tabItem {
                    Image(systemName: "list.bullet.clipboard")
                    Text("Breed list")
                }
            
            FavouritesView(store: store.scope(state: \.tab2, action: \.tab2))
                .tabItem {
                    Image(systemName: "star")
                    Text("Favourites")
                }
        }
        .tint(Color("lightCoral"))
    }
}

struct AppFeature: Reducer {
    struct State: Equatable {
        var tab1 = BreedListFeature.State()
        var tab2 = FavouritesFeature.State()
    }
    
    @CasePathable
    enum Action {
        case tab1(BreedListFeature.Action)
        case tab2(FavouritesFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.tab1, action: \.tab1) {
            BreedListFeature()
        }
        Scope(state: \.tab2, action: \.tab2) {
            FavouritesFeature()
        }
        
        Reduce { state, action in
            return .none
        }
    }
}

#Preview {
  AppView(
    store: Store(initialState: AppFeature.State()) {
      AppFeature()
    }
  )
}
