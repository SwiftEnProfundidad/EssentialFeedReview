//
//  LoadFeedFromCacheUseCaseTest.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 7/8/24.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTest: XCTestCase {
  
  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()
    
    XCTAssertEqual(store.receivedMessages, [])
  }
  
  func test_load_requestsCacheRetrieval() {
    let (sut, store) = makeSUT()
    
    sut.load { _ in }
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_load_failsOnRetrievalError() {
    let (sut, store) = makeSUT()
    let retrievalError = anyNSError()
    
    expect(sut, toCompleteWith: .failure(retrievalError)) {
      store.completeRetrieval(with: retrievalError)
    }
  }
  
  func test_load_deliversNoImagesOnEmptyCache() {
    let (sut, store) = makeSUT()
    
    expect(sut, toCompleteWith:.success([])) {
      store.completeRetrievalWithEmptyCache()
    }
  }
  
  func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
    let feed = uniqueImageFeeds()
    let currentDate = Date()
    let lessThanSevenDaysOldTimestamp = currentDate.adding(days: -7).adding(seconds: 1)
    let (sut, store) = makeSUT { currentDate }
    
    expect(sut, toCompleteWith: .success(feed.models)) {
      store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
    }
  }
  
  func test_load_deliversNoImagesOnSevenDaysOldCache() {
    let feeds = uniqueImageFeeds()
    let fixedCurrentDate = Date()
    let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    
    expect(sut, toCompleteWith: .success([])) {
      store.completeRetrieval(with: feeds.local, timestamp: sevenDaysOldTimestamp)
    }
  }
  
  // MARK: - Helpers
  
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
  
  func expect(
    _ sut: LocalFeedLoader,
    toCompleteWith expectedResult: LocalFeedLoader.LoadResult,
    when action: () -> Void,
    file: StaticString = #filePath, line: UInt = #line) {
      let exp = expectation(description: "Wait for load to completion")
      
      sut.load { receivedResult in
        switch (receivedResult, expectedResult) {
          case let (.success(receivedImages), .success(expectedImages)):
            XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            
          case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            
          default:
            XCTFail("Expected \(expectedResult), got \(String(describing: receivedResult)) instead", file: file, line: line)
        }
        exp.fulfill()
      }
      
      // En lugar de invocar un método a la `store` directamente, invocamos la acción
      action()
      wait(for: [exp], timeout: 1.0)
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
  
  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
  
  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
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




