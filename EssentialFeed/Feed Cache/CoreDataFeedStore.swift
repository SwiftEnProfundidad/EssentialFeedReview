//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 5/9/24.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
  
  public init() {}

  public func retrieve(completion: @escaping RetrievalCompletion) {
    completion(.empty)
  }
  
  public func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    
  }

  public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    
  }
  
}
