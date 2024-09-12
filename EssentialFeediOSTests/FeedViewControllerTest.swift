//
//  FeedViewControllerTest.swift
//  EssentialFeediOSTests
//
//  Created by Juan Carlos merlos albarracin on 10/9/24.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTest: XCTestCase {
  
  func test_loadFeedActions_requestFeedFromLoader() {
    let (sut, loader) = makeSUT()
    
    XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
    
    sut.loadViewIfNeeded()
    sut.refreshControl?.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
    
    sut.refreshControl?.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a reload")
    
    sut.refreshControl?.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadCallCount, 3, "Expected yet another loading request once user initiates another reload")
  }
  
  func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
    let (sut, loader) = makeSUT()
    
    sut.simulateAppearance()
    XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
    
    loader.completeFeedLoading(at: 0)
    XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")

    sut.refreshControl?.simulateUserInitiatedFeedReload()
    XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
    
    loader.completeFeedLoading(at: 1)
    XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed")
  }
  
  func test_loadFeedCompletion_rendersSuccesfullyLoadedFeed() {
    let (sut, _) = makeSUT()
    
    sut.loadViewIfNeeded()
    
    XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 0)
  }
  
  // MARK: - Helpers
  
  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (
    sut: FeedViewController, loader: LoaderSpy) {
      let loader = LoaderSpy()
      let sut = FeedViewController(loader: loader)
      trackForMemoryLeaks(sut, file: file, line: line)
      trackForMemoryLeaks(loader, file: file, line: line)
      return (sut, loader)
    }
  
  class LoaderSpy: FeedLoader {
    private var completions = [(FeedLoader.Result) -> Void]()
    
    var loadCallCount: Int {
      return completions.count
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      completions.append(completion)
    }
    
    func completeFeedLoading(at index: Int) {
      completions[index](.success([]))
    }
  }
  
}

private class FakeRefreshControl: UIRefreshControl {
  private var _isRefreshing: Bool = false
  
  override var isRefreshing: Bool { _isRefreshing }
  
  override func beginRefreshing() {
    _isRefreshing = true
  }
  
  override func endRefreshing() {
    _isRefreshing = false
  }
}

private extension FeedViewController {
  func simulateAppearance() {
    if !isViewLoaded {
      loadViewIfNeeded()
      replacerefreshControlWithFakeForiOS17Support()
    }
    
    beginAppearanceTransition(true, animated: false) // internamente es como hacer: viewWillAppear
    endAppearanceTransition() // internamente es como hacer: viewIsAppearing+viewDidAppear
  }
  
  func replacerefreshControlWithFakeForiOS17Support() {
    let fake = FakeRefreshControl()
    
    refreshControl?.allTargets.forEach { target in
      refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
        fake.addTarget(target, action: Selector(action), for: .valueChanged)
      }
    }
    refreshControl = fake
  }
  
  var isShowingLoadingIndicator: Bool {
    return refreshControl?.isRefreshing == true
  }
  
  func numberOfRenderedFeedImageViews() -> Int {
    return tableView.numberOfRows(inSection: feedImageSection)
  }
  
  private var feedImageSection: Int {
    return 0
  }
  
}

private extension UIRefreshControl {
  func simulateUserInitiatedFeedReload() {
    allTargets.forEach { target in
      actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
        (target as NSObject).perform(Selector($0))
      }
    }
  }
}
