//
//  CodableFeedStoreTest.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 27/8/24.
//

import XCTest
import EssentialFeed

protocol FeedStoreSpecs {
  func test_retrieve_deliversEmptyOnEmptyCache()
  func test_retrieve_hasNoSideEffectsOnEmptyCache()
  func test_retrieve_deliversFoundValuesOnNonEmptyCache()
  func test_retrieve_hasNoSideEffectsOnNonEmptyCache()
  func test_retrieve_hasNoSideEffectsOnNonEmptyCaches()
  
  func test_insert_deliversNoErrorOnEmptyCache()
  func test_insert_deliversNoErrorOnNonEmptyCache()
  func test_insert_overrridesPreviouslyInsertedCacheValues()
  
  
  func test_delete_deliversNoErrorOnEmptyCache()
  func test_delete_hasNoSideEffectsOnEmptyCache()
  func test_delete_deliversNoErrorOnNonEmptyCache()
  func test_delete_emptiesPreviouslyInsertedCache()
  
  func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
  func test_retrieve_deliversFailureOnRetrievalError()
  func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
  func test_insert_deliversErrorOnInsertionError()
  func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
  func test_delete_deliversErrorOnDeletionError()
  func test_delete_hasNoSideEffectsOnDeletionError()
}

typealias FailableFeedStoreSpecs = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs

final class CodableFeedStoreTest: XCTestCase, FailableFeedStoreSpecs {
  
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
  
  func test_insert_deliversErrorOnInsertionError() {
    let invalidStoreURL = URL(string: "invalid://store-url")!
    let sut = makeSUT(storeURL: invalidStoreURL)
    let news = uniqueImageFeeds().local
    let timestamp = Date()
    
    let insertionError = insert((news, timestamp), to: sut)
    
    XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
  }
  
  func test_insert_hasNoSideEffectsOnInsertionError() {
    let invalidStoreURL = URL(string: "invalid://store-url")!
    let sut = makeSUT(storeURL: invalidStoreURL)
    
    let news = uniqueImageFeeds().local
    let timestamp = Date()
    insert((news, timestamp), to: sut)
    
    expect(sut, toRetrieve: .empty)
  }
  
  func test_insert_deliversNoErrorOnEmptyCache() {
    let sut = makeSUT()
    
    let insertionError = insert((uniqueImageFeeds().local, Date()), to: sut)
    
    XCTAssertNil(insertionError, "Expected to insert cache successfully")
  }
  
  func test_insert_deliversNoErrorOnNonEmptyCache() {
    let sut = makeSUT()
    insert((uniqueImageFeeds().local, Date()), to: sut)
    
    let insertionError = insert((uniqueImageFeeds().local, Date()), to: sut)
    
    XCTAssertNil(insertionError, "Expected to override cache successfully")
  }
  
  func test_delete_deliversNoErrorOnEmptyCache() {
    let sut = makeSUT()
    
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
  }
  
  func test_delete_deliversNoErrorOnNonEmptyCache() {
    let sut = makeSUT()
    insert((uniqueImageFeeds().local, Date()), to: sut)
    
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
  }
  
  
  func test_delete_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    expect(sut, toRetrieve: .empty)
  }
  
  func test_delete_emptiesPreviouslyInsertedCache() {
    let sut = makeSUT()
    insert((uniqueImageFeeds().local, Date()), to: sut)
    
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
    expect(sut, toRetrieve: .empty)
  }
  
  func test_delete_deliversErrorOnDeletionError() {
    let noDeletePermissionURL = cachesDirectory()
    let sut = makeSUT(storeURL: noDeletePermissionURL)
    
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    expect(sut, toRetrieve: .empty)
  }
  
  func test_delete_hasNoSideEffectsOnDeletionError() {
    let noDeletePermissionURL = cachesDirectory()
    let sut = makeSUT(storeURL: noDeletePermissionURL)
    
    deleteCache(from: sut)
    
    expect(sut, toRetrieve: .empty)
  }
  
  func test_storeSideEffects_runSerially() {
    let sut = makeSUT()
    var completedOperationsInOrder = [XCTestExpectation]()
    
    let op1 = expectation(description: "Operation 1")
    sut.insert(uniqueImageFeeds().local, timestamp: Date()) { _ in
      completedOperationsInOrder.append(op1)
      op1.fulfill()
    }
    
    let op2 = expectation(description: "Operation 2")
    sut.deleteCachedFeed { _ in
      completedOperationsInOrder.append(op2)
      op2.fulfill()
    }
    
    let op3 = expectation(description: "Operation 3")
    sut.insert(uniqueImageFeeds().local, timestamp: Date()) { _ in
      completedOperationsInOrder.append(op3)
      op3.fulfill()
    }
    waitForExpectations(timeout: 5.0)
    
    XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order")
  }
  
  // MARK: - Helpers
  
  private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
    let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
    trackForMemoryLeak(sut, file: file, line: line)
    return sut
  }
  
  private func testSpecificStoreURL() -> URL {
    return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
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
  
  private func cachesDirectory() -> URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
  }
  
}

extension FeedStoreSpecs where Self: XCTestCase {
  func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedNewsResult, file: StaticString = #file, line: UInt = #line) {
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
  
  func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedNewsResult, file: StaticString = #file, line: UInt = #line) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }
  
  @discardableResult
  func insert(
    _ cache: (feed: [LocalFeedImage], timestamp: Date),
    to sut: FeedStore,
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
  
  @discardableResult
  func deleteCache(from sut: FeedStore) -> Error? {
    let exp = expectation(description: "Wait for cache deletion")
    var deletionError: Error?
    sut.deleteCachedFeed { receivedDeletionError in
      deletionError = receivedDeletionError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return deletionError
  }
}
