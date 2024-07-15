//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 15/7/24.
//

import XCTest

class URLSessionHTTPClient {
  private let session: URLSession
  
  init(session: URLSession) {
    self.session = session
  }
  
  func get(from url: URL) {
    session.dataTask(with: url) { _, _, _ in }
  }
}

final class URLSessionHTTPClientTest: XCTestCase {

  func test_getFromURL_createsDataTaskWithURL() {
    let url = URL(string: "http://any-url.com")!
    let session = URLSessionSpy()
    let sut = URLSessionHTTPClient(session: session)
    
    sut.get(from: url)
    
    XCTAssertEqual(session.receivedURLs, [url])
  }
  
  // MARK: Helpers
  
  private class URLSessionSpy: URLSession, @unchecked Sendable {
    var receivedURLs = [URL]()
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
      receivedURLs.append(url)
      return FakeURLSessionDataTask()
    }
  }

  private class FakeURLSessionDataTask: URLSessionDataTask, @unchecked Sendable {}
}
