//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 7/8/24.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
