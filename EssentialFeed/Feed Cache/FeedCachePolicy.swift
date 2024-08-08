//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 8/8/24.
//

import Foundation

final class FeedCachePolicy {
  static private let calendar = Calendar(identifier: .gregorian)
  static private var maxCacheAgeInDays: Int { return 7 }
  
  private init() {}
  
  static func validate(_ timestamp: Date, against date: Date) -> Bool {
    guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
      return false
    }
    return date < maxCacheAge
  }
}
