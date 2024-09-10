//
//  FeedViewControllerTest.swift
//  EssentialFeediOSTests
//
//  Created by Juan Carlos merlos albarracin on 10/9/24.
//

import XCTest
import UIKit

final class FeedViewController: UIViewController {
  private var loader: FeedViewControllerTest.LoaderSpy?
  
  convenience init(loader: FeedViewControllerTest.LoaderSpy) {
    self.init()
    self.loader = loader
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loader?.load()
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
  
  class LoaderSpy {
    private(set) var loadCallCount = 0
    
    func load() {
      loadCallCount += 1
    }
  }
}
