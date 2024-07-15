//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 15/7/24.
//

import XCTest

final class URLSessionHTTPClient {
  private let session: URLSession
  
  init(session: URLSession) {
    self.session = session
  }
  
  func get(from url: URL) {
    session.dataTask(with: url) { _, _, _ in }.resume()
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
  
  func test_getFromURL_resumesDataTaskWithURL() {
    let url = URL(string: "http://any-url.com")!
    let session = URLSessionSpy()
    let task = URLSessionDataTaskSpy()
    session.stub(url: url, task: task)
    
    let sut = URLSessionHTTPClient(session: session)
    
    sut.get(from: url)
    
    XCTAssertEqual(task.resumeCallCount, 1)
  }
  
  // MARK: Helpers
  
  private class URLSessionSpy: URLSession, @unchecked Sendable {
    var receivedURLs = [URL]()
    private var stubs = [URL: URLSessionDataTask]()

    func stub(url: URL, task: URLSessionDataTask) {
      stubs[url] = task
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
      receivedURLs.append(url)
      return stubs[url] ?? FakeURLSessionDataTask()

    }
  }
  
  private class URLSessionDataTaskSpy: URLSessionDataTask, @unchecked Sendable {
    var resumeCallCount = 0
    
    override func resume() {
      resumeCallCount += 1
    }
  }

  private class FakeURLSessionDataTask: URLSessionDataTask, @unchecked Sendable {
    override func resume() {}
  }
}
