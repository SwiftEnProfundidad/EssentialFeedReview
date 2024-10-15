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

    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] insertionResult in
            guard self != nil else { return }

            completion(insertionResult)
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

            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))

            case .success:
                completion(.success([]))
            }
        }
    }
}

public extension LocalFeedLoader {
    typealias ValidationResult = Result<Void, Error>

    func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }

            switch result {
            case .failure:
                self.store.deleteCachedFeed(completion: completion)

            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed(completion: completion)

            case .success:
                completion(.success(()))
            }
        }
    }
}

private extension [FeedImage] {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension [LocalFeedImage] {
    func toModels() -> [FeedImage] {
        map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
