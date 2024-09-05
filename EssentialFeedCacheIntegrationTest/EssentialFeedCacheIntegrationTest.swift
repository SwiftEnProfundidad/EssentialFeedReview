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
  }
  
  func test_load_deliversItemsSavedOnASeparateInstance() {
    let sutToPerformSave = makeSUT()
    let sutToPerformLoad = makeSUT()
    let news = uniqueImageFeed().models
    
    let saveExp = expectation(description: "Wait for save completion")
    sutToPerformSave.save(news) { saveError in
      XCTAssertNil(saveError, "Expected to save news successfully")
      saveExp.fulfill()
    }
    wait(for: [saveExp], timeout: 1.0)
    
    let loadExp = expectation(description: "Wait for load completion")
    sutToPerformLoad.load { loadResult in
      switch loadResult {
        case let .success(imageNews):
          XCTAssertEqual(imageNews, news)
          
        case let .failure(error):
          XCTFail("Expected successful news result, got \(error) instead")
          
        @unknown default:
          break
      }
      
      loadExp.fulfill()
    }
    wait(for: [loadExp], timeout: 1.0)
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
