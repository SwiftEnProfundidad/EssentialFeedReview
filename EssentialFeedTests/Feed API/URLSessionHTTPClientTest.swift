//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 15/7/24.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
  private let session: URLSession
  
  init(session: URLSession = .shared) {
    self.session = session
  }
  
  struct UnexpectedValuesRepresentation: Error {}
  
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
    session.dataTask(with: url) { _, _, error in
      if let error = error {
        completion(.failure(error))
      } else {
        completion(.failure(UnexpectedValuesRepresentation()))
      }
    }.resume()
  }
}

class URLSessionHTTPClientTests: XCTestCase {
  
  override class func setUp() {
    super.setUp()
    
    URLProtocolStub.startInterceptingRequests()
  }
  
  override class func tearDown() {
    super.tearDown()
    
    URLProtocolStub.stopInterceptingRequests()
  }
  
  func test_getFromURL_failsOnRequestError() {
    let requestError = NSError(domain: "any error", code: 1)
    let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
    
    XCTAssertNotNil(receivedError)
  }
  
  func test_getFromURL_performGETRequestWithURL() {
    let url = URL(string: "http://any-url.com")!
    let exp = expectation(description: "Wait for request")
    let sut = makeSUT()
    
    URLProtocolStub.observerRequest { request in
      XCTAssertEqual(request.url, url)
      XCTAssertEqual(request.httpMethod, "GET")
      exp.fulfill()
    }
    
    sut.get(from: url) { _ in }
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_getFromURL_failsOnAllNilValues() {
    XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
  }
  
  // MARK: - Helpers
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
    let sut = URLSessionHTTPClient()
    trackForMemoryLeak(sut)
    return sut
  }
  
  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
  
  private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
    URLProtocolStub.stub(data: data, response: response, error: error)
    
    let sut = makeSUT(file: file, line: line)
    let exp = expectation(description: "Wait for request")
    
    var receivedError: Error?
    sut.get(from: anyURL()) { result in
      switch result {
        case let .failure(error):
          receivedError = error
        default:
          XCTFail("Expected failure, got \(result) instead", file: file, line: line)
      }
      
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    
    return receivedError
  }
  
  private class URLProtocolStub: URLProtocol {
    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?
    
    private struct Stub {
      let data: Data?
      let response: URLResponse?
      let error: Error?
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
      stub = Stub(data: data, response: response, error: error)
    }
    
    static func observerRequest(observer: @escaping (URLRequest) -> Void) {
      requestObserver = observer
    }
    
    static func startInterceptingRequests() {
      URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
      URLProtocol.unregisterClass(URLProtocolStub.self)
      stub = nil
      requestObserver = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
      requestObserver?(request)
      return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      return request
    }
    
    override func startLoading() {
      if let data = URLProtocolStub.stub?.data {
        client?.urlProtocol(self, didLoad: data)
      }
      
      if let response = URLProtocolStub.stub?.response {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      }
      
      if let error = URLProtocolStub.stub?.error {
        client?.urlProtocol(self, didFailWithError: error)
      }
      
      client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
  }
  
}
