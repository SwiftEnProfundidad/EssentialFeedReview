//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 15/7/24.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient: HTTPClient {
  private let session: URLSession
  
  init(session: URLSession = .shared) {
    self.session = session
  }
  
  struct UnexpectedValuesRepresentation: Error {}
  
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
    session.dataTask(with: url) { data, response, error in
      if let error = error {
        completion(.failure(error))
      } else if let data = data, let response = response as? HTTPURLResponse {
        completion(.success(data, response))
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
    let requestError = anyError()
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
    }
    
    exp.fulfill()
    
    sut.get(from: url) { _ in }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_getFromURL_failsOnAllInvalidRepresentationCases() {
    let nonHTTPURLResponse = nonHTTPURLResponse()
    let anyHTTPURLResponse = anyHTTPURLResponse()
    let anyData = anyData()
    let anyError = anyError()
    
    XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: nil))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: anyHTTPURLResponse, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: nil))
  }
  
  func test_getFromURL_succedsOnHTTPURLResponseWithData() {
    let data = anyData()
    let response = anyHTTPURLResponse()
    
    let receivedValues = resultValuesFor(data: data, response: response, error: nil)
    
    XCTAssertEqual(receivedValues?.data, data)
    XCTAssertEqual(receivedValues?.response.url, response.url)
    XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
  }
  
  func test_getFromURL_succedsWithEmptyDataOnHTTPURLResponseWithNilData() {
    let response = anyHTTPURLResponse()
    
    let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
    
    let emptyData = Data()
    XCTAssertEqual(receivedValues?.data, emptyData)
    XCTAssertEqual(receivedValues?.response.url, response.url)
    XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
  }
  
  // MARK: - Helpers
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
    let sut = URLSessionHTTPClient()
    trackForMemoryLeak(sut)
    return sut
  }
  
  private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) throws -> HTTPClientResult {
    URLProtocolStub.stub(data: data, response: response, error: error)
    let sut = makeSUT(file: file, line: line)
    let exp = expectation(description: "Wait for completion")
    
    var receivedResult: HTTPClientResult!
    sut.get(from: anyURL()) { result in
      receivedResult = result
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
    return receivedResult
  }
  
  private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
    URLProtocolStub.stub(data: data, response: response, error: error)
    let result = try? resultFor(data: data, response: response, error: error, file: file, line: line)
    
    switch result {
      case let .failure(error):
        return error
      default:
        XCTFail("Expected failure, got \(String(describing: result)) instead", file: file, line: line)
        return nil
    }
  }
  
  private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
    let result = try? resultFor(data: data, response: response, error: error, file: file, line: line)
    
    switch result {
      case let .success(data, response):
        return (data, response)
        
      default:
        XCTFail("Expected success, got \(String(describing: result)) instead", file: file, line: line)
        return nil
    }
  }
  
  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
  
  private func anyData() -> Data {
    return Data("any data".utf8)
  }
  
  private func anyError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
  
  private func anyHTTPURLResponse() -> HTTPURLResponse {
    return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil,
                           headerFields: nil)!
  }
  
  private func nonHTTPURLResponse() -> URLResponse {
    return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0,
                       textEncodingName: nil)
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
