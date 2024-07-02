//
//  RemoteFeedLoaderTest.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 2/7/24.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        client.get(from: URL(string: "htpps://a-url.com")!)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

final class RemoteFeedLoaderTest: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client)
                
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        // Arrange: Given a client and sut
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        // Act: When we invoke sut.load()
        sut.load()
        
        // Assert: Then assert that a URL request was initiated in the client
        XCTAssertNotNil(client.requestedURL)
    }
}
