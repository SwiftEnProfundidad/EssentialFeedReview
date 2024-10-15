//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 14/10/24.
//

import Foundation

public final class FeedPresenter {
    private let feedView: FeedView
    private var errorView: FeedErrorView?
    private var loadingView: FeedLoadingView

    private var feedLoadError: String {
        NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Error message displayed when we can't load the image news from the server")
    }

    public static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Title of the feed screen")
    }

    public init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView?) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }

    public func didStartLoadingFeed() {
        errorView?.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }

    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    public func didFinishLoadingFeed(with _: Error) {
        errorView?.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
