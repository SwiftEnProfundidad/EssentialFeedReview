//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 8/8/24.
//

import Foundation

final class FeedCachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    private static var maxCacheAgeInDays: Int { 7 }

    private init() {}

    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
