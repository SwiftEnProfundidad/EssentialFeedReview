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
    let (_, view) = makeSUT()
    
    _ = FeedPresenter(view: view)
    
    XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
  }
  
  // MARK: - Helpers
  
  private func makeSUT() -> (sut: FeedPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = FeedPresenter(view: view)
    trackForMemoryLeaks(sut, file: #file, line: #line)
    trackForMemoryLeaks(view, file: #file, line: #line)
    return (sut, view)
  }
  
  private class ViewSpy {
    var messages = [Any]()
  }
}
