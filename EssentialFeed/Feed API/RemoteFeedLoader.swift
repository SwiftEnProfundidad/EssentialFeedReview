//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 2/7/24.
//

import Foundation

public final protocol HTTPClient {
    func get(from url: URL)
}

public class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient
    
   public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load() {
        client.get(from: url)
    }
}
