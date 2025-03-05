//
//  FavoriteItem.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import SwiftUI

struct FavoriteItem: View {
    let breed: CatBreed
    
    enum Messages: String {
        case emptyBreedNameText = "No breed name"
        case lifeSpanPlaceholderText = "Life span:"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(breed.name ?? Messages.emptyBreedNameText.rawValue)
                .font(.title)
            lifeSpan
        }
    }
    
    private var lifeSpan: Text {
        var result = AttributedString(breed.lifeSpan)
        result.font = .callout
        result.foregroundColor = .lightCoral
        return Text("\(Messages.lifeSpanPlaceholderText.rawValue) \(result)")
    }
}
