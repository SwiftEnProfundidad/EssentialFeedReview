//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 18/9/24.
//

import Foundation
import EssentialFeed
import UIKit

public final class FeedUIComposer {
  private init() {}
  
  public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
    let presenter = FeedPresenter()
    let presentationAdapter = FeedLoaderPresentationAdapter(loader: feedLoader, presenter: presenter)
    let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
    let feedController = FeedViewController(refreshController: refreshController)
    presenter.loadingView = WeakRefVirtualProxy(refreshController)
    presenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)
    return feedController
  }
  
  // [FeedImage] --> Adapter --> [FeedImageCellController]
  private static func adapterFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
    return { [weak controller] feed in
      controller?.tableModel = feed.map { model in
        FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init))
      }
    }
  }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
  private let loader: FeedLoader
  private let presenter : FeedPresenter
  
  init(loader: FeedLoader, presenter: FeedPresenter) {
    self.loader = loader
    self.presenter = presenter
  }
  
  func didRequestFeedRefresh() {
    presenter.didStartLoadingFeed()
    
    loader.load { [weak self] result in
      switch result {
        case let .success(feed):
          self?.presenter.didFinishLoadingFeed(with: feed)
        case let .failure(error):
          self?.presenter.didFinishLoadingFeed(with: error)
      }
    }
  }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
  weak var objetct: T?
  
  init(_ objetct: T) {
    self.objetct = objetct
  }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel) {
    objetct?.display(viewModel)
  }
}

private final class FeedViewAdapter: FeedView {
  private weak var controller: FeedViewController?
  private let imageLoader: FeedImageDataLoader
  
  init(controller: FeedViewController? = nil, imageLoader: FeedImageDataLoader) {
    self.controller = controller
    self.imageLoader = imageLoader
  }
  
  func display(_ viewModel: FeedViewModel) {
    controller?.tableModel = viewModel.feed.map { model in
      FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
    }
  }
}
