//
//  MainQueueDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 30/9/24.
//

import Foundation
import EssentialFeed

private final class MainQueueDispatchDecorator<T> {
  private let decoratee: T
  
  init(decoratee: T) {
    self.decoratee = decoratee
  }
  
  func dispatch(completion: @escaping () -> Void) {
    guard !Thread.isMainThread else {
      return DispatchQueue.main.async(execute: completion)
    }
    completion()
  }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
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
