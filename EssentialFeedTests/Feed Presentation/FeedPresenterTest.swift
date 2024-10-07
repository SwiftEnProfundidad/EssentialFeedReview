//
//  FeedPresenterTest.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 7/10/24.
//

import XCTest

final class FeedPresenter {
  init(view: Any) {
    
  }
}

final class FeedPresenterTest: XCTestCase {
  
  func test_init_doesNotSendMessagegesToView() {
    let view = ViewSpy()
    
    _ = FeedPresenter(view: view)
    
    XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
  }
  
  // MARK: - Helpers
  
  private class ViewSpy {
    var messages = [Any]()
  }
}
