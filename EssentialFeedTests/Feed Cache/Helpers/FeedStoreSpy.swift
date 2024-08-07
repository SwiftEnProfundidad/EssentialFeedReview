//
//  FeedStoreSpy.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 7/8/24.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
  private var deletionCompletions = [DeletionCompletion]()
  private var insertionCompletions = [InsertionCompletion]()
  private var retrievalCompletions = [RetrievalCompletions]()
  
  enum ReceivedMessage: Equatable {
    case deleteCacheFeed
    case insert(items: [LocalFeedImage], timestamp: Date)
    case retrieve
  }
  
  private(set) var receivedMessages = [ReceivedMessage]()
  
  func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    deletionCompletions.append(completion)
    receivedMessages.append(.deleteCacheFeed)
  }
  
  func completeInsertion(with error: Error, at index: Int = 0) {
    insertionCompletions[index](error)
  }
  
  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](error)
  }
  
  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](nil)
  }
  
  func completeInsertionSuccessfully(at index: Int = 0) {
    insertionCompletions[index](nil)
  }
  
  func insert(_ feeds: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    insertionCompletions.append(completion)
    receivedMessages.append(.insert(items: feeds, timestamp: timestamp))
  }
  
  func retrieve(completion: @escaping RetrievalCompletions) {
    retrievalCompletions.append(completion)
    receivedMessages.append(.retrieve)
  }
  
  func completeRetrieval(with error: Error, at index: Int = 0) {
    retrievalCompletions[index](.failure(error))
  }
  
  func completeRetrievalWithEmptyCache(at index: Int = 0) {
    retrievalCompletions[index](.empty)
  }
  
  func completeRetrieval(with feeds: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
    retrievalCompletions[index](.found(feeds: feeds, timestamp: timestamp))
  }

}
