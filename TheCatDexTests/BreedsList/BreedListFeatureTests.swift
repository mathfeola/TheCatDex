//
//  BreedListFeatureTests.swift
//  TheCatDex
//
//  Created by Matheus Feola on 04/03/2025.
//

import XCTest
import ComposableArchitecture
import Testing

@testable import TheCatDex

@MainActor
final class BreedListFeatureTests: XCTestCase {
    let mockBreed = CatBreed(id: "123",
                             name: "Snarf",
                             origin: "Thundera",
                             temperament: "Very scared",
                             lifeSpan: "forever",
                             breedDescription: "Snarf!",
                             image: nil,
                             isFavourite: nil)
    
    
    struct MockCatBreedService: CatBreedService {
        var fetchBreedsHandler: (Int) async throws -> [CatBreed]
        
        func fetchCatBreeds(_ page: Int) async throws -> [CatBreed] {
            try await fetchBreedsHandler(page)
        }
    }
    
    struct MockCatBreedDatabase {
        var fetchAllHandler: () throws -> [CatBreed]
        
        func fetchAll() throws -> [CatBreed] {
            try fetchAllHandler()
        }
    }
    
    func testFetchBreedListSuccess() async {
        let store = TestStore(
            initialState: BreedListFeature.State(),
            reducer: { BreedListFeature() }
        ) {
            $0.catBreedService = MockCatBreedService { _ in [self.mockBreed] }
            $0.catBreedDatabase.fetchAll = { [] }
        }
        
        await store.send(.fetchBreedList) {
            $0.isFetchingMore = true
        }
        
        await store.receive(.breedListResponse([self.mockBreed])) {
            $0.breeds = [self.mockBreed]
            $0.currentPage = 1
            $0.isFetchingMore = false
        }
    }
    
    func testFetchBreedListNetworkError() async {
        let store = TestStore(
            initialState: BreedListFeature.State(),
            reducer: { BreedListFeature() }
        ) {
            $0.catBreedService = MockCatBreedService { _ in throw FetchError.networkError(NSError(domain: "Test", code: 400)) }
            $0.catBreedDatabase.fetchAll = { [] }
        }
        
        await store.send(.fetchBreedList) {
            $0.isFetchingMore = true
        }
        
        await store.receive(.displayError("🌐 Network error: The operation couldn’t be completed. (Test error 400.)")) {
            $0.currentErrorMessage = "🌐 Network error: The operation couldn’t be completed. (Test error 400.)"
            $0.shouldShowErrorState = true
        }
    }
    
    func testFilterBreeds() async {
        let store = await TestStore(
            initialState: BreedListFeature.State(breeds: [mockBreed]),
            reducer: { BreedListFeature() }
        )
        
        await store.send(.filter("Sna")) {
            $0.filterText = "Sna"
            $0.filteredBreeds = [self.mockBreed]
        }
        
        await store.send(.filter("")) {
            $0.filterText = ""
            $0.filteredBreeds = [self.mockBreed]
        }
    }
    
    func testBreedSelection() async {
        let store = TestStore(
            initialState: BreedListFeature.State(),
            reducer: { BreedListFeature() }
        )
        
        let selectedBreed = self.mockBreed
        
        await store.send(.breedSelected(selectedBreed)) {
            $0.selectedBreed = BreedDetailFeature.State(breed: selectedBreed)
            $0.shouldOpenDetail = true
        }
    }
    
    func testCloseDetailModal() async {
        let store = TestStore(
            initialState: BreedListFeature.State(
                selectedBreed: BreedDetailFeature.State(breed: self.mockBreed),
                shouldOpenDetail: true
            ),
            reducer: { BreedListFeature() }
        )
        
        await store.send(.closeDetailModal) {
            $0.shouldOpenDetail = false
        }
    }
    
    func testFetchMoreBreeds() async {
        let store = TestStore(
            initialState: BreedListFeature.State(breeds: [self.mockBreed], currentPage: 1, isFetchingMore: false),
            reducer: { BreedListFeature() }
        ) {
            $0.catBreedService = MockCatBreedService { _ in [self.mockBreed] }
        }

        await store.send(.fetchMoreBreeds) {
            $0.isFetchingMore = true
            
        }
        await store.finish()
        await store.skipReceivedActions()
    }
}
