//
//  ValidateFeedCacheUseCase.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 8/8/24.
//

import XCTest
import EssentialFeed

final class ValidateFeedCacheUseCase: XCTestCase {
  
  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()
    
    XCTAssertEqual(store.receivedMessages, [])
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
  
  
}
