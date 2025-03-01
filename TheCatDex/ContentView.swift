//
//  ContentView.swift
//  TheCatDex
//
//  Created by Matheus Feola on 01/03/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("\(EnviromentUtil().catApiBaseUrl)")
    }
}

#Preview {
    ContentView()
}
