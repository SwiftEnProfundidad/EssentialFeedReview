//
//  RemoteFeedLoaderTest.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 2/7/24.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTest: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        // Arrange: Given a client and sut
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT()
        
        // Act: When we invoke sut.load()
        sut.load()
        
        // Assert: Then assert that a URL request was initiated in the client
        XCTAssertEqual(client.requestedURL, url)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }
}
