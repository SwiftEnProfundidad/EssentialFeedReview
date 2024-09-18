//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 18/9/24.
//

import Foundation
import EssentialFeed

public final class FeedUIComposer {
  private init() {}
  
  public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
    let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
    let feedController = FeedViewController(refreshController: refreshController)
    
    refreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
    
    return feedController
  }
  
  // [FeedImage] --> Adapt --> [FeedImageCellController]
  private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
    return { [weak controller] news in
      controller?.tableModel = news.map { model in
        FeedImageCellController(model: model, imageLoader: loader)
      }
    }
  }
  
}
