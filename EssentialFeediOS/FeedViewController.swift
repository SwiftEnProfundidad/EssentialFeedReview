//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 11/9/24.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController {
  private var viewAppeared = false
  private var loader: FeedLoader?
  
  public convenience init(loader: FeedLoader) {
    self.init()
    self.loader = loader
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
    loader?.load { [weak self] _ in
      self?.refreshControl?.endRefreshing()
    }
  }
}
