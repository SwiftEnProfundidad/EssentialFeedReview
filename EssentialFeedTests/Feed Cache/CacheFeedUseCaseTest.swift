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
  
  private var deletionCompletions = [DeletionCompletion]()
  
  enum ReceivedMessage: Equatable {
    case deleteCacheFeed
    case insert(items: [FeedItem], timestamp: Date)
  }
  
  private(set) var receivedMessages = [ReceivedMessage]()
  
  func deleteCacheFeed(completion: @escaping DeletionCompletion) {
    deletionCompletions.append(completion)
    receivedMessages.append(.deleteCacheFeed)
  }
  
  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](error)
  }
  
  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](nil)
  }
  
  func insert(_ items: [FeedItem], timestamp: Date) {
    receivedMessages.append(.insert(items: items, timestamp: timestamp))
  }
}

final class CacheFeedUseCaseTest: XCTestCase {
  
  func test_init_doesNotMessagesStoreUponCreation() {
    let (_ , store) = makeSUT()
    
    XCTAssertEqual(store.receivedMessages, [])
  }
  
  func test_save_requestsCacheDeletion() {
    let items = [uniqueItem(), uniqueItem()]
    let (sut, store) = makeSUT()
    
    sut.save(items)
    
    XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
  }
  
  func test_save_doesNotRequestCacheInsertionOnDeletionError() {
    let items = [uniqueItem(), uniqueItem()]
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()
    
    sut.save(items)
    store.completeDeletion(with: deletionError)
    
    XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
  }
  
  func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
    let timestamp = Date()
    let items = [uniqueItem(), uniqueItem()]
    let (sut, store) = makeSUT(currentDate: { timestamp })
    
    sut.save(items)
    store.completeDeletionSuccessfully()
    
    XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(items: items, timestamp: timestamp)])
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
