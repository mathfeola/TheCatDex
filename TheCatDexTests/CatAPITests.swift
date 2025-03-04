//
//  CatAPITests.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import XCTest
@testable import TheCatDex

final class CatAPITests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        MockURLProtocol.mockResponse = nil
    }
    
    func testFetchCatBreedsSuccess() async throws {
        // Sample JSON Response
        let jsonData = """
        [
            { "id": "beng", "name": "Bengal", "origin": "USA", "temperament" : "Happy", "description": "Fluffy" }
        ]
        """.data(using: .utf8)!
        
        MockURLProtocol.mockResponse = (
            data: jsonData,
            response: HTTPURLResponse(url: URL(string: "https://example.com")!,
                                      statusCode: 200,
                                      httpVersion: nil,
                                      headerFields: nil),
            error: nil
        )
        
        let result = try await CatAPI.fetchCatBreeds(page: 1).execute(using: MockURLProtocol.testSession()) as! [CatBreed]
        
        XCTAssertFalse(result.isEmpty, "Expected non-empty list")
        XCTAssertEqual(result.first?.id, "beng")
    }
    
    func testFetchCatBreedsEmptyResponse() async throws {
        MockURLProtocol.mockResponse = (
            data: "[]".data(using: .utf8)!,
            response: HTTPURLResponse(url: URL(string: "https://example.com")!,
                                      statusCode: 200,
                                      httpVersion: nil,
                                      headerFields: nil),
            error: nil
        )

        let result = try await CatAPI.fetchCatBreeds(page: 1).execute(using: MockURLProtocol.testSession()) as! [CatBreed]

        XCTAssertTrue(result.isEmpty, "Expected an empty list")
    }

    func testDecodingError() async {
        let invalidJSON = """
        { "invalid": "data" }
        """.data(using: .utf8)!
        
        MockURLProtocol.mockResponse = (
            data: invalidJSON,
            response: HTTPURLResponse(url: URL(string: "https://example.com")!,
                                      statusCode: 200,
                                      httpVersion: nil,
                                      headerFields: nil),
            error: nil
        )

        do {
            _ = try await CatAPI.fetchCatBreeds(page: 1).execute(using: MockURLProtocol.testSession())
            XCTFail("Expected decoding error, but request succeeded")
        } catch FetchError.decodingError {
            XCTAssertTrue(true, "Correctly caught decoding error")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testNetworkFailure() async {
        MockURLProtocol.mockResponse = (
            data: nil,
            response: nil,
            error: URLError(.notConnectedToInternet)
        )

        do {
            _ = try await CatAPI.fetchCatBreeds(page: 1).execute(using: MockURLProtocol.testSession())
            XCTFail("Expected network error, but request succeeded")
        } catch FetchError.networkError {
            XCTAssertTrue(true, "Correctly caught network error")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testServerError() async {
        MockURLProtocol.mockResponse = (
            data: nil,
            response: HTTPURLResponse(url: URL(string: "https://example.com")!,
                                      statusCode: 500,
                                      httpVersion: nil,
                                      headerFields: nil),
            error: nil
        )

        do {
            _ = try await CatAPI.fetchCatBreeds(page: 1).execute(using: MockURLProtocol.testSession())
            XCTFail("Expected server error, but request succeeded")
        } catch FetchError.decodingError {
            XCTAssertTrue(true, "Correctly caught server error")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
