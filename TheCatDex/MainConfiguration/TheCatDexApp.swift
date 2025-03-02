//
//  TheCatDexApp.swift
//  TheCatDex
//
//  Created by Matheus Feola on 01/03/2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct TheCatDexApp: App {
    static let store = Store(initialState: BreedListFeature.State()) {
        BreedListFeature()
      }
    
    var body: some Scene {
        WindowGroup {
            BreedsListView(store: TheCatDexApp.store)
        }
    }
}
