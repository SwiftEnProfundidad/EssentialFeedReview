//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 11/9/24.
//

import UIKit
import EssentialFeed

public protocol FeedImageDataLoaderTask {
  func cancel()
}

public protocol FeedImageDataLoader {
  typealias Result = Swift.Result<Data, Error>
  
  func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

public final class FeedViewController: UITableViewController {
  private var viewAppeared = false
  private var feedLoader: FeedLoader?
  private var imageLoader: FeedImageDataLoader?
  private var tableModel = [FeedImage]()
  private var task = [IndexPath: FeedImageDataLoaderTask]()
  
  public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
    self.init()
    self.feedLoader = feedLoader
    self.imageLoader = imageLoader
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
  }
  
  public override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)
    
    if !viewAppeared {
      refresh()
      viewAppeared = true
    }
  }
  
  @objc private func refresh() {
    refreshControl?.beginRefreshing()
    feedLoader?.load { [weak self] result in
      if let feed = try? result.get() {
        self?.tableModel = feed
        self?.tableView.reloadData()
      }
      self?.refreshControl?.endRefreshing()
    }
  }
  
  public override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableModel.count
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellModel = tableModel[indexPath.row]
    let cell = FeedImageCell()
    cell.locationContainer.isHidden = (cellModel.location == nil)
    cell.locationLabel.text = cellModel.location
    cell.descriptionLabel.text = cellModel.description
    cell.feedImageViewContainer.startShimmering()
    task[indexPath] = imageLoader?.loadImageData(from: cellModel.url) { [weak cell] result in
      cell?.feedImageViewContainer.stopShimmering()
    }
    return cell
  }
  
  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    task[indexPath]?.cancel()
    task[indexPath] = nil
  }
  
}
