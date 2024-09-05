//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 5/9/24.
//

import Foundation
import CoreData

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

private class ManagedCache: NSManagedObject {
  @NSManaged var timestamp: Date
  @NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
  @NSManaged var id: UUID
  @NSManaged var imageDescription: String?
  @NSManaged var location: String?
  @NSManaged var url: URL
  @NSManaged var cache: ManagedCache
}
