//
//  URLProtocolStub.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 15/10/24.
//

import Foundation

class URLProtocolStub: URLProtocol {
    private struct Stub {
        let onStartLoading: (URLProtocolStub) -> Void
    }

    private static var _stub: Stub?
    private static var stub: Stub? {
        get { queue.sync { _stub } }
        set { queue.sync { _stub = newValue } }
    }

    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")

    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(onStartLoading: { urlProtocol in
            guard let client = urlProtocol.client else { return }

            if let data {
                client.urlProtocol(urlProtocol, didLoad: data)
            }

            if let response {
                client.urlProtocol(urlProtocol, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error {
                client.urlProtocol(urlProtocol, didFailWithError: error)
            } else {
                client.urlProtocolDidFinishLoading(urlProtocol)
            }
        })
    }

    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        stub = Stub(onStartLoading: { urlProtocol in
            urlProtocol.client?.urlProtocolDidFinishLoading(urlProtocol)

            observer(urlProtocol.request)
        })
    }

    static func onStartLoading(observer: @escaping () -> Void) {
        stub = Stub(onStartLoading: { _ in observer() })
    }

    static func removeStub() {
        stub = nil
    }

    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        URLProtocolStub.stub?.onStartLoading(self)
    }

    override func stopLoading() {}
}
