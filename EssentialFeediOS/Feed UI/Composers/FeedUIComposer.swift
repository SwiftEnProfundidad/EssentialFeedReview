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
    
    refreshController.onRefresh = { [weak feedController] feed in
      feedController?.tableModel = feed.map { model in
        FeedImageCellController(model: model, imageLoader: imageLoader)
      }
    }
    return feedController
  }
}
