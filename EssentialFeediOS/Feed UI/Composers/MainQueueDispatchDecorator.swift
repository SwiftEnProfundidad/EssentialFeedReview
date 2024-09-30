//
//  MainQueueDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 30/9/24.
//

import Foundation
import EssentialFeed

private final class MainQueueDispatchDecorator: FeedLoader {
  private let decoratee: FeedLoader
  
  init(decoratee: FeedLoader) {
    self.decoratee = decoratee
  }
  
  func load(completion: @escaping (FeedLoader.Result) -> Void) {
    decoratee.load { result in
      if Thread.isMainThread {
        completion(result)
      } else {
        DispatchQueue.main.async {
          completion(result)
        }
      }
    }
  }
}
