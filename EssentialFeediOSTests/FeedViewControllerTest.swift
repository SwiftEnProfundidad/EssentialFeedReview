//
//  FeedViewControllerTest.swift
//  EssentialFeediOSTests
//
//  Created by Juan Carlos merlos albarracin on 10/9/24.
//

import XCTest
import UIKit
import EssentialFeed

final class FeedViewController: UIViewController {
  private var loader: FeedLoader?
  
  convenience init(loader: FeedLoader) {
    self.init()
    self.loader = loader
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loader?.load() { _ in }
  }
}

final class FeedViewControllerTest: XCTestCase {
  
  func test_init_doesNotLoadFeed() {
    let loader = LoaderSpy()
    _ = FeedViewController(loader: loader)
    
    XCTAssertEqual(loader.loadCallCount, 0)
  }
  
  func test_viewDidLoad_loadsFeed() {
    let loader = LoaderSpy()
    let sut = FeedViewController(loader: loader)
    
    sut.loadViewIfNeeded()
    XCTAssertEqual(loader.loadCallCount, 1)
  }
  
  // MARK: - Helpers
  
  class LoaderSpy: FeedLoader {
    private(set) var loadCallCount = 0
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      loadCallCount += 1
    }
  }
}
