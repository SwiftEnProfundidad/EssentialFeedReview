//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 8/8/24.
//

import Foundation

final class FeedCachePolicy {
  private let currentDate: () -> Date
  private let calendar = Calendar(identifier: .gregorian)
  
  init(currentDate: @escaping () -> Date) {
    self.currentDate = currentDate
  }

  private var maxCacheAgeInDays: Int { return 7 }
  
  func validate(_ timestamp: Date) -> Bool {
    guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
      return false
    }
    return currentDate() < maxCacheAge
  }
}
