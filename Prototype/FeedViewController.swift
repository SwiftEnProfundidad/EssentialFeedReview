//
//  FeedViewController.swift
//  Prototype
//
//  Created by Juan Carlos merlos albarracin on 10/9/24.
//

import UIKit

final class FeedViewController: UITableViewController {
  private let feed = FeedImageViewModel.prototypeFeed
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return feed.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath) as! FeedImageCell
    let model = feed[indexPath.row]
    cell.configure(with: model)
    return cell
  }
}

extension FeedImageCell {
  func configure(with viewModel: FeedImageViewModel) {
    locationLabel.text = viewModel.location
    locationContainer.isHidden = viewModel.location == nil
    
    descriptionLabel.text = viewModel.description
    descriptionLabel.isHidden = viewModel.description == nil
    
    feedImageView.image = UIImage(named: viewModel.imageName)
  }
}
