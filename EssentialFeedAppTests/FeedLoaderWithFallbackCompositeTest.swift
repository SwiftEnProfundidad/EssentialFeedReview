//
//  FeedLoaderWithFallbackCompositeTest.swift
//  EssentialFeedAppTests
//
//  Created by Juan Carlos merlos albarracin on 15/10/24.
//

import XCTest
import EssentialFeed

class FeedLoaderWithFallbackComposite {
  private let primary: FeedLoader
  private let fallback: FeedLoader
  
  init(primary: FeedLoader, fallback: FeedLoader) {
    self.primary = primary
    self.fallback = fallback
  }
  
  func load(completion: @escaping (FeedLoader.Result) -> Void) {
    primary.load { [weak self] result in
      switch result {
        case .success:
          completion(result)
          
        case .failure:
          self?.fallback.load(completion: completion)
      }
    }
  }
}
  
final class FeedLoaderWithFallbackCompositeTest: XCTestCase {
  
  func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
    let primaryFeed = uniqueFeed()
    let fallbackFeed = uniqueFeed()
    let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
    
    let exp = XCTestExpectation(description: "Wait for load completion")
    
    sut.load { result in
      switch result {
        case let .success(receivedFeed):
          XCTAssertEqual(receivedFeed, primaryFeed)
          
        case .failure:
          XCTFail("Expected successful load feed result, got \(result) instead")
      }
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_load_deliversFallbackNewsOnPrimaryFailure() {
    let fallbackFeed = uniqueFeed()
    let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))
    
    let exp = XCTestExpectation(description: "Wait for load completion")
    
    sut.load { result in
      switch result {
        case let .success(receivedFeed):
          XCTAssertEqual(receivedFeed, fallbackFeed)

        case .failure:
          XCTFail("Expected failed load feed result, got \(result) instead")
      }
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  
  // MARK: - Helpers
  
  private func makeSUT(primaryResult: FeedLoader.Result,
                       fallbackResult: FeedLoader.Result,
                       file: StaticString = #filePath,
                       line: UInt = #line) -> FeedLoaderWithFallbackComposite {
    let primaryLoader = LoaderStub(result: primaryResult)
    let fallbackLoader = LoaderStub(result: fallbackResult)
    let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
    trackMemoryLeaks(primaryLoader, file: file, line: line)
    trackMemoryLeaks(fallbackLoader, file: file, line: line)
    trackMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
      XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
    }
  }
  
  private func uniqueFeed() -> [FeedImage] {
    return [
      FeedImage(id: UUID(),
                description: "any",
                location: "any",
                url: URL(string: "http://any-url.com")!)]
  }
  
  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
  
  private class LoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
      self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      completion(result)
    }
  }
}
  
  
