//
//  CacheFeedUseCaseTest.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 2/8/24.
//

import XCTest
import EssentialFeed

final class CacheFeedUseCaseTest: XCTestCase {
  
  func test_init_doesNotMessagesStoreUponCreation() {
    let (_ , store) = makeSUT()
    
    XCTAssertEqual(store.receivedMessages, [])
  }
  
  func test_save_requestsCacheDeletion() {
    let (sut, store) = makeSUT()
    
    sut.save(uniqueImageFeeds().models) { _ in }
    
    XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
  }
  
  func test_save_doesNotRequestCacheInsertionOnDeletionError() {
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()
    
    sut.save(uniqueImageFeeds().models) { _ in }
    store.completeDeletion(with: deletionError)
    
    XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
  }
  
  func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
    let timestamp = Date()
    let feeds = uniqueImageFeeds()
    let (sut, store) = makeSUT(currentDate: { timestamp })
    
    sut.save(feeds.models) { _ in }
    store.completeDeletionSuccessfully()
    
    XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(items: feeds.local, timestamp: timestamp)])
  }
  
  func test_save_failsOnDeletionError() {
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()
    
    expect(sut, toCompletWithError: deletionError) {
      store.completeDeletion(with: deletionError)
    }
  }
  
  func test_save_failsOnInsertionError() {
    let (sut, store) = makeSUT()
    let insertionError = anyNSError()
    
    expect(sut, toCompletWithError: insertionError, when: {
      store.completeDeletionSuccessfully()
      store.completeInsertion(with: insertionError)
    })
  }
  
  func test_save_succeedssOnSuccessfulCacheInsertion() {
    let (sut, store) = makeSUT()
    
    expect(sut, toCompletWithError: nil, when: {
      store.completeDeletionSuccessfully()
      store.completeInsertionSuccessfully()
    })
  }
  
  func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
    
    var receivedResults = [Error?]()
    sut?.save(uniqueImageFeeds().models, completion: { receivedResults.append($0) })
    
    sut = nil
    store.completeDeletion(with: anyNSError())
    
    XCTAssertTrue(receivedResults.isEmpty)
  }
  
  func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
    
    var receivedResults = [Error?]()
    sut?.save(uniqueImageFeeds().models, completion: { receivedResults.append($0) })
    
    store.completeDeletionSuccessfully()
    sut = nil
    store.completeDeletion(with: anyNSError())
    
    XCTAssertTrue(receivedResults.isEmpty)
  }
  
  // MARK: Helpers
  
  private func makeSUT(
    currentDate: @escaping () -> Date = Date.init,
    file: StaticString = #file,
    line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
      let store = FeedStoreSpy()
      let sut = LocalFeedLoader(store: store, currentDate: currentDate)
      trackForMemoryLeak(store, file: file, line: line)
      trackForMemoryLeak(sut, file: file, line: line)
      return (sut, store)
    }
  
  private func expect(_ sut: LocalFeedLoader,
                      toCompletWithError expectedError: NSError?,
                      when action: () -> Void,
                      file: StaticString = #file,
                      line: UInt = #line) {
    
    let exp = expectation(description: "Wait for save completion")
    
    var receivedError: Error?
    sut.save(uniqueImageFeeds().models) { error in
      receivedError = error
      exp.fulfill()
    }
    
    action()
    wait(for: [exp], timeout: 1.0)
    
    XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
  }
  
  private func uniqueFeed() -> FeedImage {
    return FeedImage(
      id: UUID(),
      description: "any",
      location: "any",
      url: anyURL())
  }
  
  private func uniqueImageFeeds() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueFeed(), uniqueFeed()]
    let local = models.map { LocalFeedImage(
      id: $0.id,
      description: $0.description,
      location: $0.location,
      url: $0.url) }
    return (models, local)
  }
  
  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
  
  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
  
}


