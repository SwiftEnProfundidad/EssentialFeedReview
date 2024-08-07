//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 7/8/24.
//

import Foundation

public final class LocalFeedLoader {
  private let store: FeedStore
  private let currentDate: () -> Date
  
  public typealias SaveResult = Error?
  public typealias LoadResult = LoadFeedResult
  
  public init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
  
  public func load(completion: @escaping (LoadResult?) -> Void) {
    store.retrieve { result in
      switch result {
        case let .failure(error):
          completion(.failure(error))
        case let .found(feeds, _):
          completion(.success(feeds.toModels()))
        case .empty:
          completion(.success([]))
      }
    }
  }
  
  public func save(_ feeds: [FeedImage], completion: @escaping (SaveResult) -> Void) {
    store.deleteCachedFeed { [weak self] error in
      guard let self = self else { return }
      
      if let cacheDeletionError = error {
        completion(cacheDeletionError)
      } else {
        self.cache(feeds, with: completion)
      }
    }
  }
  
  public func cache(_ feeds: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
    store.insert(feeds.toLocalFeedItem(), timestamp: currentDate()) { [weak self] error in
      guard self != nil else { return }
      completion(error)
    }
  }
}

private extension Array where Element == FeedImage {
  func toLocalFeedItem() -> [LocalFeedImage] {
    return map { LocalFeedImage(id: $0.id,
                                description: $0.description,
                                location: $0.location,
                                url: $0.url) }
  }
}

private extension Array where Element == LocalFeedImage {
  func toModels() -> [FeedImage] {
    return map { FeedImage(id: $0.id,
                           description: $0.description,
                           location: $0.location,
                           url: $0.url)}
  }
}
