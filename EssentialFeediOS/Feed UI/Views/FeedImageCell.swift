//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 13/9/24.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    @IBOutlet public private(set) var locationContainer: UIView!
    @IBOutlet public private(set) var locationLabel: UILabel!
    @IBOutlet public private(set) var descriptionLabel: UILabel!
    @IBOutlet public private(set) var feedImageContainer: UIView!
    @IBOutlet public private(set) var feedImageView: UIImageView!
    @IBOutlet public private(set) var feedImageRetryButton: UIButton!

    var onRetry: (() -> Void)?
    var onReuse: (() -> Void)?

    @IBAction private func retryButtonTapped() {
        onRetry?()
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        onReuse?()
    }
}
