//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 14/10/24.
//

import Foundation

public struct FeedErrorViewModel {
    public let errorMessage: String?

    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(errorMessage: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(errorMessage: message)
    }
}
