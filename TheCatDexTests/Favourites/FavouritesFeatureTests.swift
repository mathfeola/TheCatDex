//
//  FavouritesFeatureTests.swift
//  TheCatDex
//
//  Created by Matheus Feola on 04/03/2025.
//

import XCTest
import ComposableArchitecture
import Testing
@testable import TheCatDex

@MainActor
final class FavouritesFeatureTests: XCTestCase {
    
    let mockBreeds = [
        CatBreed(id: "123",
                                        name: "Snarf",
                                        origin: "Thundera",
                                        temperament: "Very scared",
                                        lifeSpan: "forever",
                                        breedDescription: "Snarf!",
                                        image: nil,
                                        isFavourite: nil)
    ]
    
    func testFetchFavourites() async {
        let store = TestStore(
            initialState: FavouritesFeature.State(),
            reducer: { FavouritesFeature() }
        ) {
            $0.catBreedDatabase.fetchAll = { self.mockBreeds }
        }
        
        await store.send(.fetchFavourites) {
            $0.favouritesBreeds = self.mockBreeds
        }
    }
    
    func testSelectBreed() async {
        let store = TestStore(
            initialState: FavouritesFeature.State(),
            reducer: { FavouritesFeature() }
        )
        
        let selectedBreed = mockBreeds[0]
        
        await store.send(.breedSelected(selectedBreed)) {
            $0.selectedBreed = BreedDetailFeature.State(breed: selectedBreed)
            $0.shouldOpenDetail = true
        }
    }
    
    func testCloseDetailModal() async {
        let store = TestStore(
            initialState: FavouritesFeature.State(
                selectedBreed: BreedDetailFeature.State(breed: mockBreeds[0]),
                shouldOpenDetail: true
            ),
            reducer: { FavouritesFeature() }
        )
        
        await store.send(.closeDetailModal) {
            $0.shouldOpenDetail = false
        }
    }
}

