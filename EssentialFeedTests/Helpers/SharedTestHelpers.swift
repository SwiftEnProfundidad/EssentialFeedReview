//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Juan Carlos merlos albarracin on 8/8/24.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}
