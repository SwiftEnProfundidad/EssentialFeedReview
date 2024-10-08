//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 23/9/24.
//

import EssentialFeed
import Foundation

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool

    var hasLocation: Bool {
        location != nil
    }
}
