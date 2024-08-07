//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 5/7/24.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
  internal let id: UUID
  internal let description: String?
  internal let location: String?
  internal let image: URL
}

internal final class FeedItemMapper {
  private struct Root: Decodable {
    let items: [RemoteFeedItem]
  }
  
  static var OK_200: Int { return 200 }
  
  internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
    guard response.statusCode == OK_200,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
      throw RemoteFeedLoader.Error.invalidData
    }
    return root.items
  }
}
