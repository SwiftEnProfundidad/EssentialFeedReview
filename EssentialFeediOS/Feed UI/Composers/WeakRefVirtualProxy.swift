//
//  WeakRefVirtualProxy.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 30/9/24.
//

import EssentialFeed
import Foundation
import UIKit

final class WeakRefVirtualProxy<T: AnyObject> {
    weak var object: T?

    init(_ objetct: T) {
        object = objetct
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
    }
}

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel) {
        object?.display(viewModel)
    }
}
