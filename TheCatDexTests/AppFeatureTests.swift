//
//  AppFeatureTests.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import XCTest
import ComposableArchitecture
@testable import TheCatDex

@MainActor
final class AppFeatureTests: XCTestCase {
    
    func testTab1ActionD() async {
        let store = TestStore(initialState: AppFeature.State(), reducer: { AppFeature() })
        await store.send(.tab1(.displayError("Some error"))) {
            $0.tab1.shouldShowErrorState = true
            $0.tab1.currentErrorMessage = "Some error"
        }
    }
}
