//
//  FeedImageCell+TestHelpers.swift .swift
//  EssentialFeediOSTests
//
//  Created by Juan Carlos merlos albarracin on 17/9/24.
//

import UIKit

extension FeedImageCell {
  var isShowingLocation: Bool {
    return !locationContainer.isHidden
  }
  
  var isShowingImageLoadingIndicator: Bool {
    return feedImageViewContainer.isShimmering
  }
  
  var locationText: String? {
    return locationLabel.text
  }
  
  var descriptionText: String? {
    return descriptionLabel.text
  }
  
  var renderedImage: Data? {
    return feedImageView.image?.pngData()
  }
  
  var isShowingRetryAction: Bool {
    return !feedImageRetryButton.isHidden
  }
  
  func simulateRetryAction() {
    feedImageRetryButton.simulateTap()
  }
  
}
