//
//  BreedDetailFeature.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

struct BreedDetailFeature: Reducer {
    struct State: Equatable {
        var breed: CatBreed
    }
    
    enum Action {
        case favouriteButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .favouriteButtonTapped:
                return .none
            }
        }
    }
}
