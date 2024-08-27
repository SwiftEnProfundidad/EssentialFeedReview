//
//  CodableFeedStoreTest.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 27/8/24.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
  func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
    completion(.empty)
  }
}

final class CodableFeedStoreTest: XCTestCase {

  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = CodableFeedStore()
    let exp = expectation(description: "Wait for cache retrieval")
    
    sut.retrieve { result in
      switch result {
        case .empty:
          break
          
        default:
          XCTFail("Expected empty cache, got \(result) instead")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
}
