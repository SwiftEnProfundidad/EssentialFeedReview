//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 5/7/24.
//

import Foundation

enum FeedItemMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    static var OK_200: Int { 200 }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
