//
//  CacheFeedUseCaseTest.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 2/8/24.
//

import XCTest

class LocalFeedLoader {
  init(store: FeedStore) {}
}

class FeedStore {
  var deleteCacheFeedCallCount = 0
}

final class CacheFeedUseCaseTest: XCTestCase {
  
  func test_init_doesNotDeleCacheUponCreation() {
    let store = FeedStore()
    _ = LocalFeedLoader(store: store)
    
    XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
  }
}
