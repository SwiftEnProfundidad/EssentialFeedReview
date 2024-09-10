//
//  FeedViewController.swift
//  Prototype
//
//  Created by Juan Carlos merlos albarracin on 10/9/24.
//

import UIKit

final class FeedViewController: UITableViewController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: "FeedImageCell")!
  }
}
