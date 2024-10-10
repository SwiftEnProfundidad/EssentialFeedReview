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

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

public extension LocalFeedLoader {
    typealias SaveResult = Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionResult in
            guard let self else { return }

            switch deletionResult {
            case .success:
                self.cache(feed, with: completion)

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }

            switch result {
            case let .failure(error):
                completion(.failure(error))

            case let .success(.some((feed, timestamp))) where FeedCachePolicy.validate(timestamp, against: currentDate()):
                completion(.success(feed.toModels()))

            case .success:
                completion(.success([]))
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

public extension LocalFeedLoader {
    func validateCache() {
        store.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }

            case let .success(.some((feed: _, timestamp: timestamp))) where !FeedCachePolicy.validate(timestamp, against: currentDate()):
                self.store.deleteCachedFeed { _ in }

            case .success: break
            }
        }
    }
}

private extension [FeedImage] {
    func toLocalFeedItem() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id,
                             description: $0.description,
                             location: $0.location,
                             url: $0.url) }
    }
}

private extension [LocalFeedImage] {
    func toModels() -> [FeedImage] {
        map { FeedImage(id: $0.id,
                        description: $0.description,
                        location: $0.location,
                        url: $0.url) }
    }
}
