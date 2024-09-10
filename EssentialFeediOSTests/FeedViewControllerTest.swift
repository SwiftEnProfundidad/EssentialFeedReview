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
  private var loader: FeedLoader?
  
  convenience init(loader: FeedLoader) {
    self.init()
    self.loader = loader
  }
  
    override func viewDidLoad() {
      super.viewDidLoad()
      
      refreshControl = UIRefreshControl()
      refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
          
      load()
    }
  
  @objc private func load() {
    loader?.load { _ in }
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
    
    XCTAssertEqual(loader.loadCallCount, 2)
  }
  
  func test_pullToRefresh_loadsNews() {
    let (sut, loader) = makeSUT()
    
    sut.loadViewIfNeeded()
    
    sut.refreshControl?.simulatePullToRefresh()
    XCTAssertEqual(loader.loadCallCount, 2)
    
    sut.refreshControl?.simulatePullToRefresh()
    XCTAssertEqual(loader.loadCallCount, 3)
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
    private(set) var loadCallCount = 0
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      loadCallCount += 1
    }
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
