//
//  CacheFeedUseCaseTest.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 2/8/24.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
  private let store: FeedStore
  private let currentDate: () -> Date
  
  init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
  
  func save(_ items: [FeedItem]) {
    store.deleteCacheFeed { [unowned self] error in
      if error == nil {
        self.store.insert(items, timestamp: self.currentDate())
      }
    }
  }
}

class FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  
  var deleteCacheFeedCallCount = 0
  var insertions = [(items: [FeedItem], timestamp: Date)]()
  
  private var deletionCompletions = [DeletionCompletion]()
  
  func deleteCacheFeed(completion: @escaping DeletionCompletion) {
    deleteCacheFeedCallCount += 1
    deletionCompletions.append(completion)
  }
  
  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](error)
  }
  
  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](nil)
  }
  
  func insert(_ items: [FeedItem], timestamp: Date) {
    insertions.append((items, timestamp))
  }
}

final class CacheFeedUseCaseTest: XCTestCase {
  
  func test_init_doesNotDeleCacheUponCreation() {
    let (_ , store) = makeSUT()
    
    XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
  }
  
  func test_save_requestsCacheDeletion() {
    let items = [uniqueItem(), uniqueItem()]
    let (sut, store) = makeSUT()
    
    sut.save(items)
    
    XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
  }
  
  func test_save_doesNotRequestCacheInsertionOnDeletionError() {
    let items = [uniqueItem(), uniqueItem()]
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()
    
    sut.save(items)
    store.completeDeletion(with: deletionError)
    
    XCTAssertEqual(store.insertions.count, 0)
  }
  
  func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
    let timestamp = Date()
    let items = [uniqueItem(), uniqueItem()]
    let (sut, store) = makeSUT(currentDate: { timestamp })
    
    sut.save(items)
    store.completeDeletionSuccessfully()
    
    XCTAssertEqual(store.insertions.count, 1)
    XCTAssertEqual(store.insertions.first?.items, items)
    XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
  }
  
  // MARK: Helpers
  
  private func makeSUT(
    currentDate: @escaping () -> Date = Date.init,
    file: StaticString = #file,
    line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
      let store = FeedStore()
      let sut = LocalFeedLoader(store: store, currentDate: currentDate)
      trackForMemoryLeak(store, file: file, line: line)
      trackForMemoryLeak(sut, file: file, line: line)
      return (sut, store)
    }
  
  private func uniqueItem() -> FeedItem {
    return FeedItem(
      id: UUID(),
      description: "any",
      location: "any",
      imageURL: anyURL())
  }
  
  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
  
  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
  
}
