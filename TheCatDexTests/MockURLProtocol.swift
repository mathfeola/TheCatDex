//
//  MockURLProtocol.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import XCTest
@testable import TheCatDex

public class MockURLProtocol: URLProtocol {
    static var mockResponse: (data: Data?, response: URLResponse?, error: Error?)?

    public override class func canInit(with request: URLRequest) -> Bool { true }
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    public override func startLoading() {
        if let error = MockURLProtocol.mockResponse?.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = MockURLProtocol.mockResponse?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = MockURLProtocol.mockResponse?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    public override func stopLoading() { }
    
    public static func testSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }
}
