//
//  FeedViewControllerTest.swift
//  EssentialFeediOSTests
//
//  Created by Juan Carlos merlos albarracin on 10/9/24.
//

import XCTest

final class FeedViewController {
  init(loader: FeedViewControllerTest.LoaderSpy) {
    
  }
}

final class FeedViewControllerTest: XCTestCase {
  
  func test_init_doesNotLoadFeed() {
    let loader = LoaderSpy()
    let sut = FeedViewController(loader: loader)
    
    XCTAssertEqual(loader.loadCallCount, 0)
  }
  
  // MARK: - Helpers
  
  class LoaderSpy {
    private(set) var loadCallCount = 0
  }
}
