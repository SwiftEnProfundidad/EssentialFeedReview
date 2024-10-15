//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 2/7/24.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>

    func load(completion: @escaping (Result) -> Void)
}
