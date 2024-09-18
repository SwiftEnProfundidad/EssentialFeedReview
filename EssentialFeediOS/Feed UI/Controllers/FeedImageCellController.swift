//
//  FeedmageCellController.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 18/9/24.
//

import UIKit
import EssentialFeed

public final class FeedImageCellController {
  private var task: FeedImageDataLoaderTask?
  private let model: FeedImage
  private let imageLoader: FeedImageDataLoader
  
  init(model: FeedImage, imageLoader: FeedImageDataLoader) {
    self.model = model
    self.imageLoader = imageLoader
  }
  
  func view() -> UITableViewCell {
    let cell = FeedImageCell()
    cell.locationContainer.isHidden = (model.location == nil)
    cell.locationLabel.text = model.location
    cell.descriptionLabel.text = model.description
    cell.feedImageView.image = nil
    cell.feedImageRetryButton.isHidden = true
    cell.feedImageViewContainer.startShimmering()
    
    let loadImage = { [weak self, weak cell] in
      guard let self = self, let cell = cell else { return }
      
      self.task = self.imageLoader.loadImageData(from: self.model.url) { [weak cell] result in
        let data = try? result.get()
        let image = data.map(UIImage.init) ?? nil
        cell?.feedImageView.image = image
        cell?.feedImageRetryButton.isHidden = (image != nil)
        cell?.feedImageViewContainer.stopShimmering()
      }
    }
    
    cell.onRetry = loadImage
    loadImage()
    
    return cell
  }
  
  func preload() {
    task = imageLoader.loadImageData(from: model.url, completion: { _ in })
  }
  
  func cancelLoad() {
    task?.cancel()
  }
}
