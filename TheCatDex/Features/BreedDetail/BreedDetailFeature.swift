//
//  BreedDetailFeature.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import SwiftUI
import ComposableArchitecture

struct BreedDetailFeature: Reducer {
    struct State: Equatable {
        let breed: CatBreed
    }
    
    enum Action {
        case backButtonTapped
        case favouriteButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                return .none
            case .favouriteButtonTapped:
                return .none
            }
        }
    }
}

struct BreedDetailView: View {
    let store: StoreOf<BreedDetailFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Text(viewStore.breed.name ?? "Unknown Breed")
                    .font(.largeTitle)
                    .padding()
                
                breedImage
                
                Text(viewStore.breed.origin)
                    .padding()
                
                Text(viewStore.breed.temperament)
                    .padding()

                Text(viewStore.breed.description)
                    .padding()
                
                favouriteButton
                
                Spacer()
            }
        }
    }
    
    var breedImage: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if let breedImage = viewStore.breed.image,
               let url = URL(string: breedImage.url) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.pink, lineWidth: 2))
                .padding()
            }
        }
    }
    
    var favouriteButton: some View {
        Button {} label: {
            HStack {
                Image(systemName: "star")
                    .tint(.pink)
                Text("Favourite")
                    .tint(.pink)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.pink, lineWidth: 2)
            )
            .padding()
        }
    }
}
