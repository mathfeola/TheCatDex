//
//  CatBreedItemList.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

struct CatBreedItemList: View {
    let breed: CatBreed
    let placeholderSymbolName = "cat.circle"
    let isFavourite: Bool
    @State private var showingSucessAlert = false
    @State private var showingErrorAlert = false
    @Environment(\.modelContext) var modelContext
    
    enum Messages: String {
        case noCatBreedName = "No cat breed name"
        case removeFromFavourites = "Remove from Favourites"
        case saveInFavourites = "Save in Favourites"
        case updatedFavourite = "Updated favourite! 😻"
        case errorSavingFavourite = "Error saving your cat breed in device 😿"
        case unknownErrorLoadingImage = "Unknown error"
        case ok = "OK"
    }
    
    var body: some View {
        HStack {
            if let breedImage = breed.image,
               let url = URL(string: breedImage.url) {
                asyncCatImage(url: url)
            }
            Text("\(breed.name ?? Messages.noCatBreedName.rawValue)")
            Spacer()
        }
        .swipeActions {
            Button {
                isFavourite ? removeFromFavourites(breed: breed) : storeInFavourites(breed)
            } label: {
                HStack {
                    Text(isFavourite ? Messages.removeFromFavourites.rawValue : Messages.saveInFavourites.rawValue)
                        .font(.caption2)
                        .foregroundColor(isFavourite ? .green : .gray)
                }
                .padding()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("lightCoral"), lineWidth: 2)
                )
                .frame(width: 10, height: 10)
                .padding()
            }
        }
        .alert(Messages.updatedFavourite.rawValue, isPresented: $showingSucessAlert) {
            Button(Messages.ok.rawValue, role: .cancel) { }
                .tint(.lightCoral)
        }
        .alert(Messages.errorSavingFavourite.rawValue, isPresented: $showingErrorAlert) {
            Button(Messages.ok.rawValue, role: .cancel) { }
                .tint(.lightCoral)
        }
    }
    
    @ViewBuilder
    func asyncCatImage(url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.lightCoral, lineWidth: 2)
                    )
            case .failure:
                Image(systemName: placeholderSymbolName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.pink, lineWidth: 2)
                    )
            case .empty:
                ProgressView()
                    .frame(width: 40, height: 40)
            @unknown default:
                fatalError(Messages.unknownErrorLoadingImage.rawValue)
            }
        }
    }
    
    private func storeInFavourites(_ favourite: CatBreed) {
        let existingBreeds = try? modelContext.fetch(FetchDescriptor<CatBreed>())
        
        if existingBreeds?.contains(where: { $0.id == favourite.id }) == true {
            return
        }
        
        modelContext.insert(favourite)
        
        do {
            try modelContext.save()
            showingSucessAlert = true
        } catch {
            showingErrorAlert = true
        }
    }
    
    private func removeFromFavourites(breed: CatBreed) {
        let descriptor = FetchDescriptor<CatBreed>()
        if let favourites = try? modelContext.fetch(descriptor) {
            if let existingBreed = favourites.first(where: { $0.id == breed.id }) {
                modelContext.delete(existingBreed)
                try? modelContext.save()
            }
        }
    }
}
