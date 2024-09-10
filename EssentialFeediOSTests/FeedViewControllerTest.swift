//
//  FeedViewControllerTest.swift
//  EssentialFeediOSTests
//
//  Created by Juan Carlos merlos albarracin on 10/9/24.
//

import XCTest
import UIKit
import EssentialFeed

final class FeedViewController: UITableViewController {
  private var viewAppeared = false
  private var loader: FeedLoader?
  
  convenience init(loader: FeedLoader) {
    self.init()
    self.loader = loader
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
  }
  
  override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)
    
    if !viewAppeared {
      refresh()
      viewAppeared = true
    }
  }
  
  @objc private func refresh() {
    refreshControl?.beginRefreshing()
    loader?.load { [weak self] _ in
      self?.refreshControl?.endRefreshing()
    }
  }
}

final class FeedViewControllerTest: XCTestCase {
  
  func test_init_doesNotLoadFeed() {
    let (_, loader) = makeSUT()
    
    XCTAssertEqual(loader.loadCallCount, 0)
  }
  
  func test_viewDidLoad_loadsFeed() {
    let (sut, loader) = makeSUT()
    
    sut.refreshControl?.simulatePullToRefresh()
    
    XCTAssertEqual(loader.loadCallCount, 1)
  }
  
  func test_pullToRefresh_loadsNews() {
    let (sut, loader) = makeSUT()
    
    sut.loadViewIfNeeded()
    
    sut.refreshControl?.simulatePullToRefresh()
    XCTAssertEqual(loader.loadCallCount, 1)
    
    sut.refreshControl?.simulatePullToRefresh()
    XCTAssertEqual(loader.loadCallCount, 2)
  }
  
  func test_viewDidLoad_showsLoadingIndicator() {
    let (sut, _) = makeSUT()
    
    sut.simulateAppearance()
    XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    
    sut.refreshControl?.sendActions(for: .valueChanged)
    XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    
    // Evitamos que se ejecute más de una vez
    sut.refreshControl?.endRefreshing()
    sut.simulateAppearance()
    XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
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
    
    func completeFeedLoading() {
      completions[0](.success([]))
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
}

private extension UIRefreshControl {
  func simulatePullToRefresh() {
    allTargets.forEach { target in
      actions(forTarget: target, forControlEvent: .valueChanged)?
        .forEach { action in
          (target as NSObject).perform(Selector(action))
        }
    }
  }
}
