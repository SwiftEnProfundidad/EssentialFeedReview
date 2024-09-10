//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 8/8/24.
//

import Foundation
import EssentialFeed

func uniqueImageFeeds() -> (models: [FeedImage], local: [LocalFeedImage]) {
  let models = [uniqueFeed(), uniqueFeed()]
  let local = models.map { LocalFeedImage(
    id: $0.id,
    description: $0.description,
    location: $0.location,
    url: $0.url) }
  return (models, local)
}

func uniqueFeed() -> FeedImage {
  return FeedImage(
    id: UUID(),
    description: "any",
    location: "any",
    url: anyURL())
}

extension Date {
  func minusFeedCacheMaxAge() -> Date {
    return adding(days: -feedCacheMaxAgeInDays)
  }
  
  private var feedCacheMaxAgeInDays: Int {
    return 7
  }
  
  func adding(days: Int) -> Date {
    return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
  }
  
  func adding(seconds: TimeInterval) -> Date {
    return self + seconds
  }
}
