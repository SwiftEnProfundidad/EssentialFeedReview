//
//  FeedPresenterTest.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 7/10/24.
//

import XCTest

struct FeedErrorViewModel {
  let errorMessage: String?
  
  static var noError: FeedErrorViewModel {
    return FeedErrorViewModel(errorMessage: nil)
  }
}

protocol FeedErrorView {
  func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
  private var errorView: FeedErrorView
  
  init(errorView: FeedErrorView) {
    self.errorView = errorView
  }
  
  func didStartLoadingFeed() {
    errorView.display(.noError)
  }
}

final class FeedPresenterTest: XCTestCase {
  
  func test_init_doesNotSendMessagegesToView() {
    let (_, view) = makeSUT()
    
    _ = FeedPresenter(errorView: view)
    
    XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
  }
  
  func test_didStartLoadingFeed_displayNoErrorMessages() {
    let (sut, view) = makeSUT()
    
    sut.didStartLoadingFeed()
    
    XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
  }
  
  // MARK: - Helpers
  
  private func makeSUT() -> (sut: FeedPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = FeedPresenter(errorView: view)
    trackForMemoryLeaks(sut, file: #file, line: #line)
    trackForMemoryLeaks(view, file: #file, line: #line)
    return (sut, view)
  }
  
  private class ViewSpy: FeedErrorView {
    enum Message: Equatable {
      case display(errorMessage: String?)
    }
    
    private(set) var messages = [Message]()
    
    func display(_ viewModel: FeedErrorViewModel) {
      messages.append(.display(errorMessage: viewModel.errorMessage))
    }
  }
  
  
}
