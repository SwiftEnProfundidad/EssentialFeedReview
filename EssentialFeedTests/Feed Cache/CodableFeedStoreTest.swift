//
//  CodableFeedStoreTest.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 27/8/24.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
  private struct Cache: Codable {
    let feed: [LocalFeedImage]
    let timestamp: Date
  }
  
  private let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
  
  func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
    guard let data = try? Data(contentsOf: storeURL) else {
      return completion(.empty)
    }
    
    let decoder = JSONDecoder()
    let cache = try! decoder.decode(Cache.self, from: data)
    completion(.found(feeds: cache.feed, timestamp: cache.timestamp))
  }
  
  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
    let encoder = JSONEncoder()
    let encoded = try! encoder.encode(Cache(feed: feed, timestamp: timestamp))
    try! encoded.write(to: storeURL)
    completion(nil)
  }
}

final class CodableFeedStoreTest: XCTestCase {
  
  override class func setUp() {
    super.setUp()
    
    let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    try? FileManager.default.removeItem(at: storeURL)
  }
  
  override class func tearDown() {
    super.tearDown()
    
    let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    try? FileManager.default.removeItem(at: storeURL)
  }
  
  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = CodableFeedStore()
    let exp = expectation(description: "Wait for cache retrieval")
    
    sut.retrieve { result in
      switch result {
        case .empty:
          break
          
        default:
          XCTFail("Expected empty cache, got \(result) instead")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    let sut = CodableFeedStore()
    let exp = expectation(description: "Wait for cache retrieval")
    
    sut.retrieve { firstResult in
      sut.retrieve { secondResult in
        switch (firstResult, secondResult) {
          case (.empty, .empty):
            break
            
          default:
            XCTFail("Expected retrieving twice from empty cache to deliver same result, got \(firstResult) and \(secondResult) instead")
        }
        exp.fulfill()
      }
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
    let sut = CodableFeedStore()
    let feed = uniqueImageFeeds().local
    let timestamp = Date()
    let exp = expectation(description: "Wait for cache insertion")
    
    sut.insert(feed, timestamp: timestamp) { insertError in
      XCTAssertNil(insertError, "Expected to insert cache successfully")
    }
    
    sut.retrieve { retrieveResult in
      switch retrieveResult {
        case let .found(feeds: retrieveFeed, timestamp: retrieveTimestamp):
          XCTAssertEqual(retrieveFeed, feed)
          XCTAssertEqual(retrieveTimestamp, timestamp)
          
        default:
          XCTFail("Expected found result with \(feed) and timestamp \(timestamp),got \(retrieveResult) instead")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
}
