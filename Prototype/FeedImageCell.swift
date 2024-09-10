//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Juan Carlos merlos albarracin on 10/9/24.
//

import UIKit

final class FeedImageCell: UITableViewCell {
  @IBOutlet private(set) var locationContainer: UIView!
  @IBOutlet private(set) var locationLabel: UILabel!
  @IBOutlet private(set) var feedImageContainer: UIView!
  @IBOutlet private(set) var feedImageView: UIImageView!
  @IBOutlet private(set) var descriptionLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    feedImageView.alpha = 0
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    feedImageView.alpha = 0
  }
  
  func fadeIn(_ image: UIImage?) {
    feedImageView.image = image
    
    UIView.animate(
      withDuration: 0.8,
      delay: 0.8,
      options: [],
      animations: {
        self.feedImageView.alpha = 1
      })
  }

}
