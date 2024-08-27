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
    
    do {
      let decoder = JSONDecoder()
      let cache = try decoder.decode(Cache.self, from: data)
      completion(.found(feed: cache.localFeeds, timestamp: cache.timestamp))
    } catch {
      completion(.failure(error))
    }
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
  
  func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
    let sut = makeSUT()
    let feed = uniqueImageFeeds().local
    let timestamp = Date()
    
    insert((feed, timestamp), to: sut)
    
    expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
  }
  
  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()
    let feed = uniqueImageFeeds().local
    let timestamp = Date()
    
    insert((feed, timestamp), to: sut)
    
    expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
  }
  
  func test_retrieve_hasNoSideEffectsOnNonEmptyCaches() {
    let sut = makeSUT()
    let feed = uniqueImageFeeds().local
    let timestamp = Date()
    
    insert((feed, timestamp), to: sut)
    
    expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
  }
  
  func test_retrieve_deliversFailureOnRetrievalError() {
    let storeURL = testSpecificStoreURL()
    let sut = makeSUT(storeURL: storeURL)
    
    try! "invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
    
    expect(sut, toRetrieve: .failure(anyNSError()))
  }
  
  func test_retrieve_hasNoSideEffectsOnFailure() {
    let storeURL = testSpecificStoreURL()
    let sut = makeSUT(storeURL: storeURL)
    
    try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
    
    expect(sut, toRetrieveTwice: .failure(anyNSError()))
  }
  
  func test_insert_overrridesPreviouslyInsertedCacheValues() {
    let sut = makeSUT()
    let feed = uniqueImageFeeds().local
    let timestamp = Date()
    let firstInsertionError = insert((feed, timestamp), to: sut)
    
    XCTAssertNil(firstInsertionError, "Expected to override cache successfully")
    
    let latestFeed = uniqueImageFeeds().local
    let latestTimestamp = Date()
    let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
    
    XCTAssertNil(latestInsertionError, "Expected to insert to override cache successfully")
    expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
  }
  
  // MARK: - Helpers
  
  private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
    let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
    trackForMemoryLeak(sut, file: file, line: line)
    return sut
  }
  
  private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedNewsResult, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for cache retrieval")
    
    sut.retrieve { retrievedResult in
      switch (expectedResult, retrievedResult) {
        case (.empty, .empty), (.failure, .failure):
          break
          
        case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
          XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
          XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
          
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
  
  @discardableResult
  private func insert(
    _ cache: (feed: [LocalFeedImage], timestamp: Date),
    to sut: CodableFeedStore,
    file: StaticString = #file, line: UInt = #line) -> Error? {
      
      let exp = expectation(description: "Wait for cache insertion")
      var insertionError: Error?
      
      sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
        insertionError = receivedInsertionError
        exp.fulfill()
      }
      wait(for: [exp], timeout: 1.0)
      return insertionError
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
