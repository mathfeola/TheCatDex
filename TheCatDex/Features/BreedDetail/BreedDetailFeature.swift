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
        case closeButtonTapped
        case favouriteButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .closeButtonTapped:
                return .none
            case .favouriteButtonTapped:
                return .none
            }
        }
    }
}

struct BreedDetailSheet: View {
    let store: StoreOf<BreedDetailFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack {
                    Text(viewStore.breed.name ?? "Unknown Breed")
                        .font(.largeTitle)
                        .padding()
                    
                    breedImage
                    HStack(spacing: 0) {
                        Text("Origin: ")
                            .font(.title2)
                        Text(viewStore.breed.origin)
                            .font(.title3)
                            .foregroundStyle(Color("lightCoral"))
                    }
                    
                    Text("Temperament:")
                        .font(.title2)
                        .padding(.top)
                        .padding(.leading)
                        .padding(.trailing)
                    
                    makeTemperamentPills(temperament: viewStore.breed.temperament)
                        .frame(width: .leastNonzeroMagnitude)
                    
                    Text(viewStore.breed.breedDescription)
                        .font(.callout)
                        .fontWeight(.thin)
                        .padding()
                    favouriteButton
                    Spacer()
                }
            }
        }
    }
    
    var breedImage: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if let breedImage = viewStore.breed.image,
               let url = URL(string: breedImage.url) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.lightCoral, lineWidth: 2)
                        )
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
    
    @ViewBuilder
    func makeTemperamentPills(temperament: String) ->  some View {
        let temperaments = temperament.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let colors = [
            "lightCoral",
            "lightBlue",
            "lightOrange",
            "lightPurple",
            "lightGray",
            "lightMint",
        ]
        
        let temperamentColors = temperaments.map { ($0, colors.randomElement() ?? "lightPurple") }
        
        LazyHGrid(rows: [GridItem(.adaptive(minimum: 20, maximum: 50)), GridItem(.adaptive(minimum: 20, maximum: 50)), GridItem(.adaptive(minimum: 20, maximum: 50))], spacing: 4) {
            ForEach(temperamentColors, id: \.0) { temperament, color in
                Text(temperament)
                    .fontWeight(.thin)
                    .font(.caption)
                    .foregroundStyle(Color(color))
                    .padding()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(color), lineWidth: 2))
            }
        }
        .padding()
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.pink, lineWidth: 2)
        )
    }
}
