//
//  FeedImageCell+TestHelpers.swift .swift
//  EssentialFeediOSTests
//
//  Created by Juan Carlos merlos albarracin on 17/9/24.
//

import EssentialFeediOS
import UIKit

extension FeedImageCell {
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }

    var isShowingImageLoadingIndicator: Bool {
        feedImageContainer.isShimmering
    }

    var locationText: String? {
        locationLabel.text
    }

    var descriptionText: String? {
        descriptionLabel.text
    }

    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }

    var isShowingRetryAction: Bool {
        !feedImageRetryButton.isHidden
    }

    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }
}
