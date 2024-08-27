//
//  CodableFeedStoreTest.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 27/8/24.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
  private let storeURL: URL
  
  init(storeURL: URL) {
    self.storeURL = storeURL
  }
  
  private struct Cache: Codable {
    let feed: [CodableFeedImage]
    let timestamp: Date
    
    var localFeeds: [LocalFeedImage] {
      return feed.map { $0.local }
    }
  }
  
  private struct CodableFeedImage: Codable {
    let id: UUID
    let description: String?
    let location: String?
    let url: URL
    
    init(_ image: LocalFeedImage) {
      id = image.id
      description = image.description
      location = image.location
      url = image.url
    }
    
    var local: LocalFeedImage {
      return LocalFeedImage(
        id: id,
        description: description,
        location: location,
        url: url)
    }
  }
  
  func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
    guard let data = try? Data(contentsOf: storeURL) else {
      return completion(.empty)
    }
    
    let decoder = JSONDecoder()
    let cache = try! decoder.decode(Cache.self, from: data)
    completion(.found(feed: cache.localFeeds, timestamp: cache.timestamp))
  }
  
  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
    let encoder = JSONEncoder()
    let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
    let encoded = try! encoder.encode(cache)
    try! encoded.write(to: storeURL)
    completion(nil)
  }
}

final class CodableFeedStoreTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
    
    setupEmptyStoreState()
  }
  
  override func tearDown() {
    super.tearDown()
    
    undoStoreSideEffects()
  }
  
  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = makeSUT()
    
    expect(sut, toRetrieve: .empty)
  }
  
  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    
    expect(sut, toRetrieveTwice: .empty)
  }
  
  func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
    let sut = makeSUT()
    let feed = uniqueImageFeeds().local
    let timestamp = Date()
    let exp = expectation(description: "Wait for cache insertion")
    
    sut.insert(feed, timestamp: timestamp) { insertError in
      XCTAssertNil(insertError, "Expected to insert cache successfully")
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    
    expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
  }
  
  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()
    let feed = uniqueImageFeeds().local
    let timestamp = Date()
    let exp = expectation(description: "Wait for cache retrieval")
    
    sut.insert(feed, timestamp: timestamp) { insertionError in
      XCTAssertNil(insertionError, "Expected to insert cache successfully")
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    
    expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
  }
  
  func test_retrieve_hasNoSideEffectsOnNonEmptyCaches() {
    let sut = makeSUT()
    let feed = uniqueImageFeeds().local
    let timestamp = Date()
    let exp = expectation(description: "Wait for cache retrieval")
    
    sut.insert(feed, timestamp: timestamp) { insertionError in
      XCTAssertNil(insertionError, "Expected to insert cache successfully")
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    
    expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
  }
  
  // MARK: - Helpers
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
    let storeURL = testSpecificStoreURL()
    let sut = CodableFeedStore(storeURL: storeURL)
    trackForMemoryLeak(sut, file: file, line: line)
    return sut
  }
  
  private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedNewsResult, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for cache retrieval")
    
    sut.retrieve { retrievedResult in
      switch (expectedResult, retrievedResult) {
        case (.empty, .empty):
          break
          
        case let (.found(expectedNews, expectedTimestamp),
                  .found(retrievedNews, retrievedTimestamp)):
          XCTAssertEqual(retrievedNews, expectedNews, file: file, line: line)
          XCTAssertEqual(retrievedTimestamp, expectedTimestamp,
                         file: file, line: line)
          
        default:
          XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
      }
      
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedNewsResult, file: StaticString = #file, line: UInt = #line) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }
  
  private func testSpecificStoreURL() -> URL {
    let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    return storeURL
  }
  
  private func setupEmptyStoreState() {
    deleteStoreArtifacts()
  }
  
  private func undoStoreSideEffects() {
    deleteStoreArtifacts()
  }
  
  private func deleteStoreArtifacts() {
    try? FileManager.default.removeItem(at: testSpecificStoreURL())
  }
  
}
