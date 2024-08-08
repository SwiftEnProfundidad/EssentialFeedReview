//
//  ValidateFeedCacheUseCaseTest.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 8/8/24.
//

import XCTest
import EssentialFeed

final class ValidateFeedCacheUseCaseTest: XCTestCase {
  
  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()
    
    XCTAssertEqual(store.receivedMessages, [])
  }
  
  func test_load_hasNoSideEffectsOnRetrievalError() {
    let (sut, store) = makeSUT()
    
    sut.load { _ in }
    store.completeRetrieval(with: anyNSError())
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_validateCache_deletesCacheOnRetrievalError() {
    let (sut, store) = makeSUT()
    
    sut.validateCache()
    store.completeRetrieval(with: anyNSError())
    
    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
  }
  
  func test_validate_doesNotDeletesCacheOnEmptyCache() {
    let (sut, store) = makeSUT()
    
    sut.validateCache()
    store.completeRetrievalWithEmptyCache()
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_validateCache_doesNotDeletesCacheOnLessThanSevenDaysOldCache() {
    let feeds = uniqueImageFeeds()
    let fixedCurrentDate = Date()
    let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    
    sut.validateCache()
    store.completeRetrieval(with: feeds.local, timestamp: lessThanSevenDaysOldTimestamp)
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  // MARK: - Helpers
  
  private func makeSUT(
    currentDate: @escaping () -> Date = Date.init,
    file: StaticString = #file, line: UInt = #line)
  -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeak(sut, file: file, line: line)
    trackForMemoryLeak(store, file: file, line: line)
    return (sut, store)
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
  
  private func uniqueFeed() -> FeedImage {
    return FeedImage(
      id: UUID(),
      description: "any",
      location: "any",
      url: anyURL())
  }
  
  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
  
  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
  
}

private extension Date {
  func adding(days: Int) -> Date {
    return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
  }
  
  func adding(seconds: TimeInterval) -> Date {
    return self + seconds
  }
}
