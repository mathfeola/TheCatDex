//
//  BreedsListView.swift
//  TheCatDex
//
//  Created by Matheus Feola on 01/03/2025.
//

import SwiftUI
import ComposableArchitecture

struct BreedsListView: View {
    var body: some View {
        Text("Hello, World!")
            .onAppear {
                print(EnvironmentUtil().catApiKey)
            }
    }
}
