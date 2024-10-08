//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 24/7/24.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    private struct UnexpectedValuesRepresentation: Error {}

    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let error {
                    throw error
                } else if let data,
                          let response = response as? HTTPURLResponse
                {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }.resume()
    }
}
