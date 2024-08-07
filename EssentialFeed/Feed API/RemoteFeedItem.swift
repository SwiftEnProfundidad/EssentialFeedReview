//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 7/8/24.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
  internal let id: UUID
  internal let description: String?
  internal let location: String?
  internal let image: URL
}
