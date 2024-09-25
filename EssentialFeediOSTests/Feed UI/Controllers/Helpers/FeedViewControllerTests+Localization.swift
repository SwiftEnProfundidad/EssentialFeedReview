//
//  FeedViewControllerTests+Localization.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 25/9/24.
//

import Foundation
import XCTest
import EssentialFeediOS

extension FeedViewControllerTests {
  func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
    let table = "Feed"
    let bundle = Bundle(for: FeedViewController.self)
    let value = bundle.localizedString(forKey: key, value: nil, table: table)
    
    if value == key {
      XCTFail("Missing localized string for key: \(key)", file: file, line: line)
    }
    return value
  }
}
