//
//  TheCatDexApp.swift
//  TheCatDex
//
//  Created by Matheus Feola on 01/03/2025.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

@main
struct TheCatDexApp: App {
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
      }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: TheCatDexApp.store)
        }
        .modelContainer(SwiftDataModelConfigurationProvider.shared.container)
    }
}
