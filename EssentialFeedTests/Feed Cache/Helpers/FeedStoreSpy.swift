//
//  FeedStoreSpy.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 7/8/24.
//

import EssentialFeed
import Foundation

class FeedStoreSpy: FeedStore {
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()

    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert(items: [LocalFeedImage], timestamp: Date)
        case retrieve
    }

    private(set) var receivedMessages = [ReceivedMessage]()

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }

    func insert(_ feeds: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items: feeds, timestamp: timestamp))
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }

    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }

    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](.success(.none))
    }

    func completeRetrieval(with feeds: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrievalCompletions[index](.success(CachedFeed((feed: feeds, timestamp: timestamp))))
    }
}
