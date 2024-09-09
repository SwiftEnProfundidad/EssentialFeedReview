//
//  EssentialFeedCacheIntegrationTest.swift
//  EssentialFeedCacheIntegrationTest
//
//  Created by Juan Carlos merlos albarracin on 5/9/24.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
    
    setupEmptyStoreState()
  }
  
  override func tearDown() {
    super.tearDown()
    
    undoStoreSideEffects()
  }
  
  
  func test_load_deliversNoItemsOnEmptyCache() {
    let sut = makeSUT()
    
    let exp = expectation(description: "Wait for load completion")
    sut.load { result in
      switch result {
        case let .success(imageFeed):
          XCTAssertEqual(imageFeed, [], "Expected empty news")
          
        case let .failure(error):
          XCTFail("Expected successful news result, got \(error) instead")
        @unknown default:
          break
      }
      
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    expect(sut, toLoad: [])
  }
  
  func test_load_deliversItemsSavedOnASeparateInstance() {
    let sutToPerformSave = makeSUT()
    let sutToPerformLoad = makeSUT()
    let feed = uniqueImageFeed().models
    
    save(feed, with: sutToPerformSave)
    
    expect(sutToPerformLoad, toLoad: feed)
  }
  
  func test_save_overridesItemsSavedOnASeparateInstance() {
    let sutToPerformFirstSave = makeSUT()
    let sutToPerformLastSave = makeSUT()
    let sutToPerformLoad = makeSUT()
    let firstFeed = uniqueImageFeed().models
    let latestFeed = uniqueImageFeed().models
    
    save(firstFeed, with: sutToPerformFirstSave)
    save(latestFeed, with: sutToPerformLastSave)
    
    expect(sutToPerformLoad, toLoad: latestFeed)
  }
  
  // MARK: - Helpers
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
    let storeBundle = Bundle(for: CoreDataFeedStore.self)
    let storeURL = testSpecificStoreURL()
    let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
    let sut = LocalFeedLoader(store: store, currentDate: Date.init)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func expect(_ sut: LocalFeedLoader, toLoad expectedNews: [FeedImage], file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    sut.load { result in
      switch result {
        case let .success(loadNews):
          XCTAssertEqual(loadNews, expectedNews, file: file, line: line)
          
        case let .failure(error):
          XCTFail("Expected successful news result, got \(error) instead",
                  file: file, line: line)
        @unknown default:
          break
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  private func save(_ feed: [FeedImage], with loader: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
    let saveExp = expectation(description: "Wait for save completion")
    loader.save(feed) { result in
      if case let Result.failure(error) = result {
        XCTFail("Expected to save feed successfully, got error: \(error)", file: file, line: line)
      }
      saveExp.fulfill()
    }
    wait(for: [saveExp], timeout: 1.0)
  }
  
  private func testSpecificStoreURL() -> URL {
    return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
  }
  
  private func cachesDirectory() -> URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
  }
  
  
  private func setupEmptyStoreState() {
    deleteStoreArtifacts()
  }
  
  private func undoStoreSideEffects() {
    deleteStoreArtifacts()
  }
  
  private func deleteStoreArtifacts() {
    try? FileManager.default.removeItem(at: testSpecificStoreURL())
  }
  
}
