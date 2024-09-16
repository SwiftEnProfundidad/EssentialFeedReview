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
    XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")
    
    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")
    
    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a reload")
    
    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected yet another loading request once user initiates another reload")
  }
  
  func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
    let (sut, loader) = makeSUT()
    
    sut.simulateAppearance()
    XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
    
    loader.completeFeedLoading(at: 0)
    XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
    
    sut.simulateUserInitiatedFeedReload()
    XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
    
    loader.completeFeedLoadingWithError(at: 1)
    XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
  }
  
  func test_loadFeedCompletion_rendersSuccesfullyLoadedFeed() {
    let image0 = makeImage(description: "a description", location: "a location")
    let image1 = makeImage(description: nil, location: "another location")
    let image2 = makeImage(description: "another description", location: nil)
    let image3 = makeImage(description: nil, location: nil)
    let (sut, loader) = makeSUT()
    
    sut.simulateAppearance()
    assertThat(sut, isRendering: [])
    
    loader.completeFeedLoading(with: [image0], at: 0)
    assertThat(sut, isRendering: [image0])
    
    sut.simulateUserInitiatedFeedReload()
    loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
    assertThat(sut, isRendering: [image0, image1, image2, image3])
  }
  
  func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
    let image0 = makeImage()
    let (sut, loader) = makeSUT()
    
    sut.simulateAppearance()
    loader.completeFeedLoading(with: [image0], at: 0)
    assertThat(sut, isRendering: [image0])
    
    sut.simulateUserInitiatedFeedReload()
    loader.completeFeedLoadingWithError(at: 1)
    assertThat(sut, isRendering: [image0])
  }
  
  func test_feedImageView_loadsImageURLWhenVisible() {
    let image0 = makeImage(url: URL(string: "http://url-0.com")!)
    let image1 = makeImage(url: URL(string: "http://url-1.com")!)
    let (sut, loader) = makeSUT()

    sut.simulateAppearance()
    loader.completeFeedLoading(with: [image0, image1], at: 0)
    XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")
    
    sut.simulateFeedImageViewVisible(at: 0)
    XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first URL request once first image view becomes visible")
    
    sut.simulateFeedImageViewVisible(at: 1)
    XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second image view becomes visible")
  }
  
  func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
    let image0 = makeImage(url: URL(string: "http://url-0.com")!)
    let image1 = makeImage(url: URL(string: "http://url-1.com")!)
    let (sut, loader) = makeSUT()
    
    sut.simulateAppearance()
    loader.completeFeedLoading(with: [image0, image1])
    XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")
    
    sut.simulateFeedImageViewNotVisible(at: 0)
    XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected one cancelled image URL request once first image is not visible anymore")
    
    sut.simulateFeedImageViewNotVisible(at: 1)
    XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected two cancelled image URL requests once second image is also not visible anymore")

  }
  
  // MARK: - Helpers
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (
    sut: FeedViewController, loader: LoaderSpy) {
      let loader = LoaderSpy()
      let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
      trackForMemoryLeaks(sut, file: file, line: line)
      trackForMemoryLeaks(loader, file: file, line: line)
      return (sut, loader)
    }
  
  private func assertThat(
    _ sut: FeedViewController,
    hasViewConfiguredFor image: FeedImage,
    at index: Int,
    file: StaticString = #file,
    line: UInt = #line)  {
      let view = sut.feedImagesView(at: index)
      
      guard let cell = view as? FeedImageCell else {
        return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
      }
      
      let shouldLocationBeVisible = (image.location != nil)
      XCTAssertEqual(
        cell.isShowingLocation,
        shouldLocationBeVisible,
        "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index \(index)",
        file: file,
        line: line
      )
      
      XCTAssertEqual(
        cell.locationLabel.text,
        image.location,
        "Expected location text to be \(String(describing: image.location)) for image view at index (\(index))",
        file: file,
        line: line)
      
      XCTAssertEqual(
        cell.descriptionLabel.text,
        image.description,
        "Expected description text to be \(String(describing: image.description)) for image view at index (\(index))",
        file: file,
        line: line)
    }
  
  private func assertThat(
    _ sut: FeedViewController,
    isRendering feed: [FeedImage],
    file: StaticString = #file,
    line: UInt = #line) {
      guard sut.numberOfRenderedFeedImageViews() == feed.count else {
        return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
      }
      
      feed.enumerated().forEach { index, image in
        assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
      }
    }
  
  
  private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "https://a-url.com")!) -> FeedImage {
    return FeedImage(id: UUID(), description: description, location: location, url: url)
  }
  
  class LoaderSpy: FeedLoader, FeedImageDataLoader {
    
    // MARK: - FeedLoader

    private var feedRequest = [(FeedLoader.Result) -> Void]()
    
    var loadFeedCallCount: Int {
      return feedRequest.count
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      feedRequest.append(completion)
    }
    
    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
      feedRequest[index](.success(feed))
    }
    
    func completeFeedLoadingWithError(at index: Int = 0) {
      let error = NSError(domain: "an error", code: 0)
      feedRequest[index](.failure(error))
    }
    
    // MARK: - FeedImageDataLoader

    private(set) var loadedImageURLs = [URL]()
    private(set) var cancelledImageURLs = [URL]()

    func loadImageData(from url: URL) {
      loadedImageURLs.append(url)
    }
    
    func cancelImageDataLoading(from url: URL) {
      cancelledImageURLs.append(url)
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
  func simulateUserInitiatedFeedReload() {
    refreshControl?.simulatePullToRefresh()
  }
  
  @discardableResult
  func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
    return feedImageView(at: index) as? FeedImageCell
  }
  
  func simulateFeedImageViewNotVisible(at row: Int) {
    let view = feedImagesView(at: row)
    let delegate = tableView.delegate
    let index = IndexPath(row: row, section: feedImagesSection)
    delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
  }

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
    return tableView.numberOfRows(inSection: feedImagesSection)
  }
  
  private var feedImagesSection: Int {
    return 0
  }
  
  func feedImagesView(at row: Int) -> UITableViewCell? {
    let ds = tableView.dataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    return ds?.tableView(tableView, cellForRowAt: index)
  }
  
  func feedImageView(at row: Int) -> UITableViewCell? {
    let ds = tableView.dataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    return ds?.tableView(tableView, cellForRowAt: index)
  }
  
}

private extension UIRefreshControl {
  func simulatePullToRefresh() {
    allTargets.forEach { target in
      actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
        (target as NSObject).perform(Selector($0))
      }
    }
  }
}

private extension FeedImageCell {
  var isShowingLocation: Bool {
    return !locationContainer.isHidden
  }
  
  var locationText: String? {
    return locationLabel.text
  }
  
  var descriptionText: String? {
    return descriptionLabel.text
  }
}

