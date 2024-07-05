//
//  HTTClient.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 5/7/24.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
